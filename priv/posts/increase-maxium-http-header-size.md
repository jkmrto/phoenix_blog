---
author: "Juan Carlos Martinez de la Torre"
date: 2023-01-09
linktitle: increase-header-size-ingres-phoenix
menu:
  main:
    parent: tutorials
title: How to increase the maximum size of headers in Phoenix and Ingress
intro: Debugging a 431 `Request Header Fields Too Large` from an application running in Kubernetes can be quite tricky. At this post, it is explained a real life scenario, how it was approched the debugging and the final solution.
---

## The 431 error

Lately, at my current company, we started to get a 431 HTTP error. This error is defined as `Request Header Fields Too Large`, so a big header was causing us some trouble. Fortunately, this happened in the preproduction environment, so nothing was burning out :)

Example of the page being rendered:

![](https://i.imgur.com/TzkJu9U.png)

This error has been triggered due to some new headers that have been added by Cloudflare, [after setting up the access layer of Cloudflare.](https://developers.cloudflare.com/cloudflare-one/identity/authorization-cookie/)

## Troubleshooting

So we have the issue, and now we need to find a workaround for it. My first thought was to identify the component that was triggering the error, since the appliation is running in a Kubernetes cluster, the error could be triggered by the application itself or by the ingress.

To identify the component, I took a look at the logs of both the ingress and the application. **There were no traces on the application**, while on the logs of the [ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) I could see that indeed a 431 error was triggered:

```
"GET / HTTP/2.0" 431 0 "-" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36" 3788 0.001 [****] [] 10.56.0.232:4000 0 0.000 431 1f4a7e96067224974a5f966f31aa82db
```

It looked like the ingress rejected the request. So, I focused on applying a fix on the ingress side.

## Fix on the ingress

Googling about how to increase the maximum allowed header size for an HTTP request, I found this thread on the [ingress-nginx](https://github.com/kubernetes/ingress-nginx/issues/4593) repository. It is possible to configure the ingress through the [ConfigMap](https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/configmap.md). I added, these entries under the config map:

```yaml=
data:
  client-header-buffer-size: "16k"
  http2-max-field-size: "8k"
  http2-max-header-size: "16k"
```

To confirm that the change was effective, I took a look to the configuration applied inside the `ingress controller`. On the pod, at the file `/etc/nginx/nginx.conf` it is possible to see the configuration of the nginx. The configuration was correctly applied since the values were changed over that file.

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

**Unfortunately, the error was still shown.**

## Fix on the application

I started to wonder if the error was in the application. I did some checks:

1. **Inside a pod which runs the application**, applying the same request (with the same exact headers) that was triggering the error  with `curl`. **Surprisingly, the application handled the request correctly**, which made me even more unsure about why the ingress fix was not working
2. **Locally**, applying the same request over an instance of the application. As expected, it handled the request correctly.
3. **Locally**, I reduced the maximum header size allowed by Phoenix from 4096 bytes, the default size, to 128 bytes using this configuration:

```elixir=
# conf/config.exs
config :my_app, MyApp.Endpoint,
  http: [:inet6, port: 4000, protocol_options: [max_header_value_length: 128]],
```

Applying the same request over this new configuration triggered successfully the error. Surprisingly, this didn't show any error on the elixir console, so maybe the same could be happening in the deployed application.

Just as a quick test, I decided to deploy a change in the configuration on the application. Setting a higher value on the max header size.

**After that deployment, the error 431 was not shown anymore. In the end, the error was coming from the application, although the lack of logs in the application was misleading about that.**

## Final thoughts

In my opinion, the main misleading point here is that the application was able to handle the request correctly isolatedly, but an error was triggered when the request was routed by the ingress.

Based on that scenario, the reasonable fix is what we did, just increasing the size of allowed headers on the ingress. However, applying the fix on the application was what makes finally the trick, so it looked like I was missing something there.

What I didn't take into account is that some special headers are set by the nginx. Those headers are not part of the original request, but they arrive to the application.

<div style="margin-bottom: 20px; display: flex; justify-content: center">
<img  src="../images/ingress-diagram.png" width="500px" alt="X headers diagram">

</div>

This could be the reason why the request works inside the pod, but not when passing through the nginx. These are these special headers set by the nginx:

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

Although we have not added any log to confirm that this is the reason, it makes sense that these headers increase the total size of the headers, triggering the 431 error on the application.
