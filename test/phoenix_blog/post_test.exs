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

  @tag :tmp_dir
  test "parse/1 builds a table of contents linked to h2/h3 ids", %{tmp_dir: tmp_dir} do
    path = Path.join(tmp_dir, "toc-post.md")

    File.write!(path, """
    title: TOC post
    date: 2024-01-02
    ---
    ## First section

    ### Use `setup_all/1`

    ## Second & last
    """)

    content = Post.parse(path).content

    assert content =~
             ~s(<div id="table_of_contents_container"><h2>Table Of Contents</h2>) <>
               ~s(<li><a class="toc" href="#first-section">First section</a></li>) <>
               ~s(<ul><li><a class="toc" href="#use-setup_all/1">Use setup_all/1</a></li></ul>) <>
               ~s(<li><a class="toc" href="#second-&amp;-last">Second &amp; last</a></li></div>)

    assert content =~ ~s(<h2 id="first-section">First section</h2>)
    assert content =~ ~s(<h3 id="use-setup_all/1">Use <code class="inline">setup_all/1</code></h3>)
    assert content =~ ~s(<h2 id="second-&amp;-last">Second &amp; last</h2>)
  end

  @tag :tmp_dir
  test "parse/1 skips the table of contents when toc is false", %{tmp_dir: tmp_dir} do
    path = Path.join(tmp_dir, "no-toc-post.md")

    File.write!(path, """
    title: No TOC
    date: 2024-01-02
    toc: false
    ---
    ## Only section
    """)

    content = Post.parse(path).content

    refute content =~ "table_of_contents_container"
    assert content =~ "<h2>Only section</h2>"
  end
end
