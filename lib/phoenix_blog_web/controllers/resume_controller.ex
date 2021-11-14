defmodule PhoenixBlogWeb.ResumeController do
  use PhoenixBlogWeb, :controller

  def index(conn, _) do
    conn
    |> assign(:title, "Resume")
    |> render("index.html")
  end
end
