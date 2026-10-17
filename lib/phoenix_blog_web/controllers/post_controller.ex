defmodule PhoenixBlogWeb.PostController do
  use PhoenixBlogWeb, :controller

  def show(conn, %{"slug" => slug}) do
    case PhoenixBlog.Repo.get_by_slug(slug) do
      {:ok, post} -> render(conn, "show.html", post: post, title: post.title)
      :not_found -> not_found(conn)
    end
  end

  def index(conn, _) do
    {:ok, posts} = PhoenixBlog.Repo.list()
    render(conn, "index.html", posts: posts, title: "Posts")
  end

  def not_found(conn) do
    conn
    |> put_status(:not_found)
    |> put_view(PhoenixBlogWeb.ErrorHTML)
    |> render(:"404", title: "Not Found")
  end
end
