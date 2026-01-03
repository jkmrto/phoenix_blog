defmodule PhoenixBlogWeb.Components.Layout do
  use Phoenix.Component
  use PhoenixHTMLHelpers

  import Phoenix.Controller, only: [get_flash: 1, get_flash: 2]
  alias PhoenixBlogWeb.Router.Helpers, as: Routes

  @default_title "jkmrto"

  def title(%{title: title}), do: "#{title} - #{@default_title}"
  def title(_assigns), do: @default_title

  def app(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title><%= title(assigns) %></title>
        <link rel="stylesheet" href={Routes.static_path(PhoenixBlogWeb.Endpoint, "/css/app.css")} />
        <script defer type="text/javascript" src={Routes.static_path(PhoenixBlogWeb.Endpoint, "/js/app.js")}>
        </script>
        <!-- Global site tag (gtag.js) - Google Analytics -->
        <script async src="https://www.googletagmanager.com/gtag/js?id=G-0T4NY8QTPE">
        </script>
        <script>
          window.dataLayer = window.dataLayer || [];

          function gtag() {
            dataLayer.push(arguments);
          }
          gtag("js", new Date());

          gtag("config", "G-0T4NY8QTPE");
        </script>
      </head>

      <body>
        <header id="header">
          <PhoenixBlogWeb.NavBarHTML.nav_bar />
          <PhoenixBlogWeb.NavBarHTML.nav_bar_mobile title={@title} />
        </header>
        <main role="main" id="main-container" class="container">
          <p class="alert alert-info" role="alert"><%= get_flash(@conn, :info) %></p>
          <p class="alert alert-danger" role="alert"><%= get_flash(@conn, :error) %></p>
          <%= @inner_content %>
        </main>
        <PhoenixBlogWeb.Components.LayoutComponents.footer />
      </body>
    </html>
    """
  end
end
