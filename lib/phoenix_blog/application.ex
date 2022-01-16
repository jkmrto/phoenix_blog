defmodule PhoenixBlog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: PhoenixBlog.PubSub},
      # Start the Endpoint (http/https)
      PhoenixBlogWeb.Endpoint,
      # Start a worker by calling: PhoenixBlog.Worker.start_link(arg)
      # {PhoenixBlog.Worker, arg}
      PhoenixBlog.Repo
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixBlog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PhoenixBlogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
