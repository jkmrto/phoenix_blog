defmodule PhoenixBlogWeb.LandingController do
  use PhoenixBlogWeb, :controller

  def index(conn, _) do
    conn
    |> assign(:title, "Landing")
    |> assign(:latest_posts, Enum.take(PhoenixBlog.Crawler.list_posts(), 3))
    |> render("index.html")
  end
end
