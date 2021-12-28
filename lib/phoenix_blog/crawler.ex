defmodule PhoenixBlog.Crawler do
  posts_paths = Path.wildcard("priv/posts/*.md")

  #  IO.inspect(posts_paths)
  # posts_paths = ["priv/posts/setup-prettier-for-heex-files.md"]

  posts =
    for post_path <- posts_paths do
      @external_resource Path.relative_to_cwd(post_path)
      PhoenixBlog.Post.parse(post_path)
    end

  @posts Enum.sort_by(posts, & &1.date, {:desc, Date})

  def list_posts() do
    @posts
  end
end
