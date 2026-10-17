defmodule PhoenixBlogWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, channels and so on.

  This can be used in your application as:

      use PhoenixBlogWeb, :controller

  The definitions below will be executed for every
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller,
        namespace: PhoenixBlogWeb,
        formats: [:html, :json],
        layouts: [html: {PhoenixBlogWeb.Components.Layout, :app}]

      import Plug.Conn
      use Gettext, backend: PhoenixBlogWeb.Gettext
      alias PhoenixBlogWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      use Gettext, backend: PhoenixBlogWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
