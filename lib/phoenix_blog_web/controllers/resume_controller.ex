defmodule PhoenixBlogWeb.ResumeController do
  use PhoenixBlogWeb, :controller

  def index(conn, _), do: render(conn, "index.html")
end
