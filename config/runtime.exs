import Config

config :phoenix_blog, PhoenixBlog.Mailer, api_key: System.get_env("SENDGRID_API_KEY")

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise "environment variable SECRET_KEY_BASE is missing. Generate one with: mix phx.gen.secret"

  config :phoenix_blog, PhoenixBlogWeb.Endpoint,
    http: [port: String.to_integer(System.get_env("PORT", "4000"))],
    secret_key_base: secret_key_base

  config :recaptcha,
    public_key: System.get_env("RECAPTCHA_PUBLIC_KEY"),
    secret: System.get_env("RECAPTCHA_PRIVATE_KEY")
end
