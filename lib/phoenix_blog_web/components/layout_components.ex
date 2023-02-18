defmodule PhoenixBlogWeb.Components.LayoutComponents do
  import Phoenix.Component

  def footer(assigns) do
    ~H"""
    <footer class="flex-column">
      <div id="container" class="d-flex justify-content-around">
        <div class="d-flex flex-column">
          <a href="/posts" target="_blank">Posts</a>
          <a href="/resume" target="_blank">Resume</a>
          <a href="/contact" target="_blank">Contact</a>
          <a href="https://www.jkmrto.dev" target="_blank">www.jkmrto.dev @ 2023</a>
        </div>
        <div class="d-flex flex-column">
          <a href="https://github.com/jkmrto/phoenix_blog" target="_blank">Code at Github</a>
          <a href="https://elixir-lang.org/" target="_blank">Written with Elixir</a>
          <a href="https://www.phoenixframework.org/" target="_blank">Built with Phoenix</a>
          <a href="https://github.com/pragdave/earmark" target="_blank">
            Markdown posts rendered with earmark
          </a>
        </div>
      </div>
    </footer>
    """
  end
end
