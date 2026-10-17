defmodule PhoenixBlog.PostTest do
  use ExUnit.Case

  alias PhoenixBlog.Post

  @tag :tmp_dir
  test "parse/1 builds a post with language-prefixed code blocks", %{tmp_dir: tmp_dir} do
    path = Path.join(tmp_dir, "my-post.md")

    File.write!(path, """
    title: My post
    date: 2024-01-02
    intro: Intro
    ---
    #{File.read!("test/fixtures/code_post.md")}
    """)

    post = Post.parse(path)

    assert post.slug == "my-post"
    assert post.title == "My post"
    assert post.date == ~N[2024-01-02 00:00:00]
    assert post.content =~ ~s(<pre class="language-elixir"><code class="language-elixir">)
  end
end
