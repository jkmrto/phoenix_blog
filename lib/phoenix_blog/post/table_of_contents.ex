defmodule PhoenixBlog.Post.TableOfContents do
  @toc_title {"h2", [], ["Table Of Contents"], %{}}

  def process_md_with_links(ast) do
    [@toc_title] ++ build_ast_toc(ast) ++ add_id_to_titles(ast)
  end

  def build_ast_toc(ast) do
    ast
    |> filter_titles()
    |> divide_by_h2()
    |> Enum.map(&build_li_with_sublist(&1))
    |> Enum.flat_map(& &1)
  end

  def filter_titles(ast) do
    ast
    |> Enum.filter(fn {type, _, _, _} -> type in ["h2", "h3"] end)
    |> Enum.map(fn {type, _attrs, [text], _} -> {type, text} end)
  end

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

  def build_toc_entry(id, text) do
    link_node = {"a", [{"class", "toc"}, {"href", "#" <> id}], [text], %{}}
    {"li", [], link_node, %{}}
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

  defp build_id(text) do
    text
    |> String.downcase()
    |> String.replace(" ", "-")
  end
end
