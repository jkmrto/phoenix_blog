defmodule PhoenixBlogWeb.NavBarHTML do
  use Phoenix.Component
  use PhoenixHTMLHelpers

  alias PhoenixBlogWeb.Router.Helpers, as: Routes

  def nav_bar(assigns) do
    ~H"""
    <section id="nav-bar" class="container">
      <div class="d-flex flex-row justify-content-end w-100 px-5">
        <.links />
      </div>
    </section>
    """
  end

  def nav_bar_mobile(assigns) do
    ~H"""
    <section id="nav-bar-mobile" class="container">
      <div class="d-flex flex-column align-items-start p-3">
        <div class="d-flex w-100 align-items-center">
          <a
            id="menu-icon"
            class="fas fa-bars menu-icon"
            type="button"
            data-toggle="collapse"
            data-target="#collapseExample"
            aria-expanded="false"
            aria-controls="collapseExample"
          >
          </a>

          <span class="mx-5" id="nav-bar-title"><%= @title %></span>
        </div>
        <div class="collapse mt-2" id="collapseExample">
          <.links />
        </div>
      </div>
    </section>
    """
  end

  def links(assigns) do
    ~H"""
    <div class="nav-link">
      <.link href={Routes.landing_path(PhoenixBlogWeb.Endpoint, :index)}>Landing</.link>
    </div>
    <div class="nav-link">
      <.link href={Routes.post_path(PhoenixBlogWeb.Endpoint, :index)}>Posts</.link>
    </div>
    <div class="nav-link">
      <.link href={Routes.resume_path(PhoenixBlogWeb.Endpoint, :index)}>Resume</.link>
    </div>
    <div class="nav-link">
      <.link href={Routes.contact_path(PhoenixBlogWeb.Endpoint, :index)}>Contact</.link>
    </div>
    """
  end
end
