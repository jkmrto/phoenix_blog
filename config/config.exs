# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :phoenix_blog, PhoenixBlogWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "UF2mY/FssOeWGtS9zpWUHbA4Tdt9M/7QtFf3V+pBKl+fG2uF//k2qupvw0LFkgnq",
  render_errors: [view: PhoenixBlogWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PhoenixBlog.PubSub,
  live_view: [signing_salt: "OePVNPRn"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# config/config.exs
config :phoenix_blog, PhoenixBlog.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: {:system, "SENDGRID_API_KEY"}

config :recaptcha, :json_library, Jason

config :recaptcha,
  public_key: "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI",
  secret: "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"

# {:system, "RECPATCHA_PRIVATE_KEY"} ||

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
