defmodule PhoenixBlog.Post.Toc do
  @moduledoc """
  Builds a table of contents from the top-level h2/h3 headings of a post
  and sets an `id` on each of those headings so the TOC links can target them.
  """

  @levels [2, 3]

  def setup(%MDEx.Document{nodes: nodes} = doc, options) do
    %{doc | nodes: [build_toc(nodes) | Enum.map(nodes, &put_heading_id(&1, options))]}
  end

  defp put_heading_id(%MDEx.Heading{level: level} = heading, options) when level in @levels do
    id = heading |> text() |> build_id() |> escape()
    tag = "h#{level}"

    html =
      %MDEx.Document{nodes: [heading]}
      |> MDEx.to_html!(options)
      |> String.replace_prefix("<#{tag}>", ~s(<#{tag} id="#{id}">))

    %MDEx.HtmlBlock{literal: html}
  end

  defp put_heading_id(node, _options), do: node

  defp build_toc(nodes) do
    entries =
      nodes
      |> Enum.filter(&match?(%MDEx.Heading{level: level} when level in @levels, &1))
      |> Enum.map(&{&1.level, text(&1)})
      |> group_by_h2()
      |> Enum.map_join(fn {h2, h3s} -> entry(h2) <> sublist(h3s) end)

    %MDEx.HtmlBlock{
      literal:
        ~s(<div id="table_of_contents_container"><h2>Table Of Contents</h2>) <>
          entries <> "</div>\n"
    }
  end

  defp group_by_h2(headings) do
    headings
    |> Enum.reduce([], fn
      {2, text}, acc -> [{text, []} | acc]
      {3, text}, [{h2, h3s} | rest] -> [{h2, [text | h3s]} | rest]
      {3, _text}, [] -> []
    end)
    |> Enum.map(fn {h2, h3s} -> {h2, Enum.reverse(h3s)} end)
    |> Enum.reverse()
  end

  defp sublist([]), do: ""
  defp sublist(texts), do: "<ul>" <> Enum.map_join(texts, &entry/1) <> "</ul>"

  defp entry(text) do
    ~s(<li><a class="toc" href="##{escape(build_id(text))}">#{escape(text)}</a></li>)
  end

  defp text(%MDEx.HtmlInline{literal: html}), do: html |> String.replace(~r/<[^>]*>/, "") |> unescape()
  defp text(%{literal: literal}) when is_binary(literal), do: literal
  defp text(%{nodes: nodes}), do: Enum.map_join(nodes, &text/1)
  defp text(_node), do: ""

  defp build_id(text) do
    text
    |> String.downcase()
    |> String.replace(" ", "-")
  end

  defp escape(text), do: Plug.HTML.html_escape(text)

  defp unescape(text) do
    text
    |> String.replace("&lt;", "<")
    |> String.replace("&gt;", ">")
    |> String.replace("&quot;", "\"")
    |> String.replace("&#39;", "'")
    |> String.replace("&amp;", "&")
  end
end
