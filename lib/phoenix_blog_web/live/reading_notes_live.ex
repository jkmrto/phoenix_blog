defmodule PhoenixBlogWeb.Live.ReadingNotesLive do
  use Phoenix.LiveView

  # TODO:
  # Trigger not found error
  # Create Live View on Endpoint file
  # Anchor footnote

  def render(assigns) do
    ~H"""
    <%= Phoenix.HTML.raw(@content) %>
    """
  end

  def mount(params, _session, socket) do
    %{"book" => book_slug} = params

    book_notes = PhoenixBlog.NotesCrawler.notes(book_slug)

    socket = assign(socket, title: book_notes.title)
    socket = assign(socket, content: book_notes.content)

    {:ok, socket}
  end
end
