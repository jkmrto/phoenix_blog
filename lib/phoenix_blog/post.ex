defmodule PhoenixBlog.Post do
  alias PhoenixBlog.Post
  defstruct slug: "", title: "", date: Timex.now(), intro: "", content: ""

  def parse(path) do
    {props, content} =
      path
      |> File.read!()
      |> split()

    %Post{
      slug: file_to_slug(path),
      title: Map.get(props, "title"),
      date: Timex.parse!(to_string(Map.get(props, "date")), "{ISOdate}"),
      intro: Map.get(props, "intro"),
      content: content
    }
  end

  defp file_to_slug(file) do
    file
    |> String.split("/")
    |> List.last()
    |> String.replace(~r/\.md$/, "")
  end

  def split(data) do
    [frontmatter, markdown] = String.split(data, ~r/\n-{3,}\n/, parts: 2)

    {parse_yaml(frontmatter),
     Earmark.as_html!(markdown, %Earmark.Options{
       code_class_prefix: "lang-",
       smartypants: false
     })}
  end

  defp parse_yaml(yaml) do
    yaml
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ": "))
    |> Enum.filter(&(length(&1) == 2))
    |> Enum.into(%{}, fn [a, b] -> {a, b} end)
  end
end
