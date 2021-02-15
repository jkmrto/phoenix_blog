defmodule PhoenixBlog.Repo do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  def get_by_slug(slug), do: GenServer.call(__MODULE__, {:get_by_slug, slug})
  def list(), do: GenServer.call(__MODULE__, :list)

  def init(:ok) do
    posts = PhoenixBlog.Crawler.crawl()
    {:ok, posts}
  end

  def handle_call({:get_by_slug, slug}, _from, posts) do
    case Enum.find(posts, fn x -> x.slug == slug end) do
      nil -> {:reply, :not_found, posts}
      post -> {:reply, {:ok, post}, posts}
    end
  end

  def handle_call(:list, _from, posts) do
    ordered_posts =
      Enum.reduce(posts, %{}, fn post, acc ->
        current = Map.get(acc, post.date.year, [])
        Map.put(acc, post.date.year, [post | current])
      end)

    {:reply, {:ok, ordered_posts}, posts}
  end
end
