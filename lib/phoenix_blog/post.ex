defmodule PhoenixBlog.Post do
  alias PhoenixBlog.Post
  alias PhoenixBlog.Post.Properties
  alias EarmarkTocGenerator

  defstruct slug: "", title: "", date: Timex.now(), intro: "", content: ""

  def read_post(path) do
    [raw_properties, markdown] =
      path
      |> File.read!()
      |> String.split(~r/\n-{3,}\n/, parts: 2)

    {markdown, Properties.parse_yaml(raw_properties)}
  end

  def parse(path) do
    {markdown, props} = read_post(path)

    %Post{
      slug: file_to_slug(path),
      title: Map.get(props, "title"),
      date: Timex.parse!(to_string(Map.get(props, "date")), "{ISOdate}"),
      intro: Map.get(props, "intro"),
      content: build_content(markdown, props)
    }
  end

  defp build_content(markdown, props) do
    {:ok, ast, []} = EarmarkParser.as_ast(markdown)

    ast
    |> Enum.map(&apply_code_language_preffix(&1))
    |> add_toc(props)
    |> Earmark.Transform.transform()
  end

  defp add_toc(ast, props)
  defp add_toc(ast, %{"add_toc" => true}), do: EarmarkTocGenerator.setup_toc(ast)
  defp add_toc(ast, _props), do: ast

  defp file_to_slug(file) do
    file
    |> String.split("/")
    |> List.last()
    |> String.replace(~r/\.md$/, "")
  end

  defp apply_code_language_preffix(
         {"pre", [], [{"code", [{"class", language}], [text], %{}}], %{}}
       ) do
    class_tuple = {"class", "language-#{language}"}
    {"pre", [class_tuple], [{"code", [class_tuple], [text], %{}}], %{}}
  end

  defp apply_code_language_preffix(other_node), do: other_node
end
