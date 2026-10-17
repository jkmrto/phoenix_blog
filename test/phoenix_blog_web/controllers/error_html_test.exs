defmodule PhoenixBlogWeb.ErrorHTMLTest do
  use PhoenixBlogWeb.ConnCase, async: true

  import Phoenix.Template, only: [render_to_string: 4]

  test "renders 404.html" do
    assert render_to_string(PhoenixBlogWeb.ErrorHTML, "404", "html", []) == "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(PhoenixBlogWeb.ErrorHTML, "500", "html", []) ==
             "Internal Server Error"
  end

  test "unknown post slug returns 404", %{conn: conn} do
    assert conn |> get("/posts/does-not-exist") |> html_response(404) =~ "Not Found"
  end
end
