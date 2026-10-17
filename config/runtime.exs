import Config

config :phoenix_blog, PhoenixBlog.Mailer, api_key: System.get_env("SENDGRID_API_KEY")

if config_env() == :prod do
  config :phoenix_blog, PhoenixBlogWeb.Endpoint,
    http: [port: String.to_integer(System.get_env("PORT", "4000"))]

  config :recaptcha,
    public_key: System.get_env("RECAPTCHA_PUBLIC_KEY"),
    secret: System.get_env("RECAPTCHA_PRIVATE_KEY")
end
