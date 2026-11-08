defmodule PhoenixBlogWeb.Components.LayoutComponents do
  import Phoenix.Component

  def footer(assigns) do
    ~H"""
    <footer class="flex-column justify-content-around">
      <div id="container" class="d-flex justify-content-md-around .justify-content-start flex-wrap">
        <div class="d-flex flex-column">
          <a href="/posts">Posts</a>
          <a href="/resume">Resume</a>
          <a href="/contact">Contact</a>
          <a href="https://www.jkmrto.dev">www.jkmrto.dev © {Date.utc_today().year}</a>
        </div>
        <div class="d-flex flex-column">
          <a href="https://github.com/jkmrto/phoenix_blog" target="_blank">Code at Github</a>
          <a href="https://elixir-lang.org/" target="_blank">Written with Elixir</a>
          <a href="https://www.phoenixframework.org/" target="_blank">Built with Phoenix</a>
          <a href="https://github.com/leandrocp/mdex" target="_blank">
            Markdown posts rendered with MDEx
          </a>
        </div>
      </div>
    </footer>
    """
  end
end
