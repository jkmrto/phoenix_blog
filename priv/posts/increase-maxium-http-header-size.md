---
author: "Juan Carlos Martinez de la Torre"
date: 2023-01-09
linktitle: increase-header-size-ingres-phoenix
menu:
  main:
    parent: tutorials
title: How to increase the maximum size of headers in Phoenix and Ingress
intro: Debugging a 431 `Request Header Fields Too Large` from an application running in Kubernetes can be quite tricky. This post explains a real-life scenario, how the debugging was approached, and the final solution.
---

## The 431 error

Lately, at my current company, we started to get a 431 HTTP error. This error is defined as `Request Header Fields Too Large`, so a big header was causing us some trouble. Fortunately, this happened in the preproduction environment, so nothing was on fire :)

Example of the page being rendered:

![](https://i.imgur.com/TzkJu9U.png)

This error was triggered by some new headers added by Cloudflare [after setting up Cloudflare's access layer.](https://developers.cloudflare.com/cloudflare-one/identity/authorization-cookie/)

## Troubleshooting

So we had the issue, and now we needed to find a workaround for it. My first thought was to identify the component that was triggering the error. Since the application runs in a Kubernetes cluster, the error could be triggered by the application itself or by the ingress.

To identify the component, I took a look at the logs of both the ingress and the application. **There were no traces on the application**, while in the logs of the [ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) I could see that indeed a 431 error was triggered:

```
"GET / HTTP/2.0" 431 0 "-" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36" 3788 0.001 [****] [] 10.56.0.232:4000 0 0.000 431 1f4a7e96067224974a5f966f31aa82db
```

It looked like the ingress rejected the request. So, I focused on applying a fix on the ingress side.

## Fix on the ingress

Googling about how to increase the maximum allowed header size for an HTTP request, I found this thread on the [ingress-nginx](https://github.com/kubernetes/ingress-nginx/issues/4593) repository. It is possible to configure the ingress through the [ConfigMap](https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/configmap.md). I added these entries to the ConfigMap:

```yaml=
data:
  client-header-buffer-size: "16k"
  http2-max-field-size: "8k"
  http2-max-header-size: "16k"
```

To confirm that the change was effective, I took a look at the configuration applied inside the `ingress controller`. In the pod, the file `/etc/nginx/nginx.conf` shows the nginx configuration. The configuration was correctly applied, since the values had changed in that file.

```nginx=
# /etc/nginx/nginx.conf
http {
   ....
   client_header_buffer_size       16k;
   ....
   http2_max_field_size            8k;
   http2_max_header_size           16k;
   ....
}
```

**Unfortunately, the error was still there.**

## Fix on the application

I started to wonder if the error was in the application. I did some checks:

1. **Inside a pod running the application**, I sent the same request (with exactly the same headers) that was triggering the error using `curl`. **Surprisingly, the application handled the request correctly**, which made me even more unsure about why the ingress fix was not working.
2. **Locally**, I sent the same request to an instance of the application. As expected, it handled the request correctly.
3. **Locally**, I reduced the maximum header size allowed by Phoenix from 4096 bytes, the default size, to 128 bytes using this configuration:

```elixir=
# conf/config.exs
config :my_app, MyApp.Endpoint,
  http: [:inet6, port: 4000, protocol_options: [max_header_value_length: 128]],
```

Sending the same request with this new configuration successfully triggered the error. Surprisingly, it didn't show any error in the Elixir console, so maybe the same thing was happening in the deployed application.

Just as a quick test, I decided to deploy a configuration change to the application, setting a higher value for the max header size.

**After that deployment, the 431 error was gone. In the end, the error was coming from the application, although the lack of logs in the application was misleading.**

## Final thoughts

In my opinion, the most misleading point here is that the application was able to handle the request correctly in isolation, but an error was triggered when the request was routed through the ingress.

Based on that scenario, the reasonable fix was what we did first: increasing the allowed header size on the ingress. However, applying the fix to the application was what finally did the trick, so it looked like I was missing something there.

What I didn't take into account is that nginx sets some special headers. Those headers are not part of the original request, but they reach the application.

<div style="margin-bottom: 20px; display: flex; justify-content: center">
<img  src="../images/ingress-diagram.png" width="500px" alt="X headers diagram">

</div>

This could be why the request works inside the pod, but not when passing through nginx. These are the special headers set by nginx:

```nginx
# /etc/nginx/nginx.conf
proxy_set_header X-Request-ID           $req_id;
proxy_set_header X-Real-IP              $remote_addr;
proxy_set_header X-Forwarded-For        $remote_addr;
proxy_set_header X-Forwarded-Host       $best_http_host;
proxy_set_header X-Forwarded-Port       $pass_port;
proxy_set_header X-Forwarded-Proto      $pass_access_scheme;
proxy_set_header X-Forwarded-Scheme     $pass_access_scheme;
proxy_set_header X-Scheme               $pass_access_scheme;

# Pass the original X-Forwarded-For
proxy_set_header X-Original-Forwarded-For $http_x_forwarded_for;
```

Although we have not added any logs to confirm that this is the reason, it makes sense that these headers increase the total size of the headers, triggering the 431 error in the application.
