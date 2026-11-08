defmodule PhoenixBlogWeb.PageControllerTest do
  use PhoenixBlogWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    html = html_response(conn, 200)
    assert html =~ "Hi, I'm Juan Carlos"
    assert html =~ "Latest posts"
  end
end
