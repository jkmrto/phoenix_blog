defmodule PhoenixBlog.Post do
  alias PhoenixBlog.Post
  defstruct slug: "", title: "", date: Timex.now(), intro: "", content: ""

  @options %Earmark.Options{
    code_class_prefix: "lang-",
    smartypants: false
  }
  def parse(path) do
    case path do
      "priv/posts/test.md" -> wtf("priv/posts/test.md")
      _ -> ast_processing(path)
    end
  end

  def apply_code_language_preffix(
        {"pre", [], [{"code", [{"class", language}], [text], %{}}], %{}}
      ) do
    class_tuple = {"class", "language-#{language}"}
    {"pre", [class_tuple], [{"code", [class_tuple], [text], %{}}], %{}}
  end

  def apply_code_language_preffix(other_node), do: other_node

  def wtf(path) do
    [frontmatter, markdown] =
      path
      |> File.read!()
      |> String.split(~r/\n-{3,}\n/, parts: 2)

    {props, _content} = {parse_yaml(frontmatter), Earmark.as_html!(markdown, @options)}

    {:ok, ast, []} = EarmarkParser.as_ast(markdown)

    content =
      ast
      |> Enum.map(&apply_code_language_preffix(&1))
      |> Earmark.Transform.transform()

    %Post{
      slug: file_to_slug(path),
      title: Map.get(props, "title"),
      date: Timex.parse!(to_string(Map.get(props, "date")), "{ISOdate}"),
      intro: Map.get(props, "intro"),
      content: content
    }
  end

  def ast_processing(path) do
    [frontmatter, markdown] =
      path
      |> File.read!()
      |> String.split(~r/\n-{3,}\n/, parts: 2)

    # TODO: How to use this same function for all the other ??
    {props, _content} = {parse_yaml(frontmatter), Earmark.as_html!(markdown, @options)}

    add_toc? = if props["toc"] == "false", do: false, else: true
    content = process_markdown_with_links(markdown, add_toc?)

    %Post{
      slug: file_to_slug(path),
      title: Map.get(props, "title"),
      date: Timex.parse!(to_string(Map.get(props, "date")), "{ISOdate}"),
      intro: Map.get(props, "intro"),
      content: content
    }
  end

  def apply_languague_code_preffix(ast) do
    IO.inspect(ast)
  end

  def filter_titles(ast) do
    ast
    |> Enum.filter(fn {type, _, _, _} -> type in ["h2", "h3"] end)
    |> Enum.map(fn {type, _attrs, [text], _} -> {type, text} end)
  end

  def convert!("true"), do: true
  def convert!("false"), do: false
  # No the most efficiente way but the most expressive
  def divide_by_h2(ast) do
    ast
    |> Enum.reduce([], fn node, acc ->
      case {node, acc} do
        {{"h2", text}, []} ->
          [{"h2", text, []}]

        {{"h2", text1}, [{"h2", text2, childs} | rest]} ->
          [{"h2", text1, []} | [{"h2", text2, Enum.reverse(childs)} | rest]]

        {other_node, [{"h2", text, childs} | rest]} ->
          [{"h2", text, [other_node | childs]} | rest]
      end
    end)
    |> Enum.reverse()
  end

  def add_id_to_titles(ast) do
    ast
    |> Enum.reduce([], fn node, nodes_acc ->
      case node do
        {"h2", [], [text], rest} ->
          id = build_id(text)
          node_with_link = {"h2", [{"id", id}], [text], rest}
          [node_with_link | nodes_acc]

        other ->
          [other | nodes_acc]
      end
    end)
    |> Enum.reverse()
  end

  def process_markdown_with_links(markdown, add_toc?) do
    {:ok, ast, []} = EarmarkParser.as_ast(markdown)

    content =
      ast
      |> add_id_to_titles()
      |> Enum.map(&apply_code_language_preffix(&1))

    content =
      if add_toc? do
        new_toc =
          ast
          |> filter_titles()
          |> divide_by_h2()
          |> Enum.map(&build_li_with_sublist(&1))
          |> Enum.flat_map(& &1)

        toc_title = {"h2", [], ["Table Of Contents"], %{}}
        [toc_title] ++ new_toc ++ content
      else
        content
      end

    Earmark.Transform.transform(content, @options)
  end

  def build_toc_entry(id, text) do
    link_node = {"a", [{"class", "toc"}, {"href", "#" <> id}], [text], %{}}
    {"li", [], link_node, %{}}
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

  def build_ul_node_with_list([]), do: nil

  def build_ul_node_with_list(elements_list) do
    childs =
      Enum.map(elements_list, fn
        {type, text} ->
          build_li_with_sublist({type, text, []})

        {type, text, childs} ->
          build_li_with_sublist({type, text, childs})
      end)
      |> Enum.flat_map(& &1)

    {"ul", [], childs, %{}}
  end

  def build_li_with_sublist({_type, text, sublist}) do
    entry = build_toc_entry(build_id(text), text)

    case build_ul_node_with_list(sublist) do
      nil -> [entry]
      sublist_entries -> [entry, sublist_entries]
    end
  end

  defp parse_yaml(yaml) do
    yaml
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ": "))
    |> Enum.filter(&(length(&1) == 2))
    |> Enum.into(%{}, fn [a, b] -> {a, b} end)
  end

  defp build_id(text) do
    text
    |> String.downcase()
    |> String.replace(" ", "-")
  end
end
