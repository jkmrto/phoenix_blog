import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phoenix_blog, PhoenixBlogWeb.Endpoint,
  secret_key_base: "UF2mY/FssOeWGtS9zpWUHbA4Tdt9M/7QtFf3V+pBKl+fG2uF//k2qupvw0LFkgnq",
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warning
