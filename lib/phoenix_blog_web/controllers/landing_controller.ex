defmodule PhoenixBlogWeb.LandingController do
  use PhoenixBlogWeb, :controller

  def index(conn, _) do
    conn
    |> assign(:title, "Landing")
    |> render("index.html")
  end
end
