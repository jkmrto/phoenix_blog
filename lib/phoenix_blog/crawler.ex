defmodule PhoenixBlog.Crawler do
  posts_paths = Path.wildcard("priv/posts/*.md")

  posts =
    for post_path <- posts_paths do
      @external_resource Path.relative_to_cwd(post_path)
      PhoenixBlog.Post.parse(post_path)
    end

  IO.inspect(posts |> Enum.sort_by(& &1.date, {:desc, Date}) |> Enum.map(& &1.date))

  @posts Enum.sort_by(posts, & &1.date, {:desc, Date})

  def list_posts() do
  IO.inspect(@posts |> Enum.map(& &1.date))
    IO.inspect(@posts |> Enum.map(& &1.title))
    @posts
  end
end
