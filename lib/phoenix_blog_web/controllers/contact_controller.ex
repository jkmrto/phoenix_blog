defmodule PhoenixBlogWeb.ContactController do
  use PhoenixBlogWeb, :controller

  def index(conn, _), do: render(conn, "index.html")

  def create(conn = %{params: params}, _) do
    PhoenixBlog.Email.email(
      params["name"],
      params["subject"],
      params["email"],
      params["message"]
    )

    render(conn, "index.html")
  end
end
