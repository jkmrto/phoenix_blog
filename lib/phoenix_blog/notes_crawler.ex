defmodule PhoenixBlog.NotesCrawler do
  reading_notes_paths = Path.wildcard("priv/reading-notes/*.md")

  Enum.each(reading_notes_paths, &(@external_resource(Path.relative_to_cwd(&1))))

  reading_notes =
    reading_notes_paths
    |> Enum.map(&PhoenixBlog.Post.parse(&1))
    |> Enum.map(&{&1.slug, &1})
    |> Enum.into(%{})

  @reading_notes reading_notes

  def notes(book), do: Map.fetch!(@reading_notes, book)
end
