defmodule PhoenixBlog.Post do
  alias PhoenixBlog.Post
  alias PhoenixBlog.Post.Properties
  alias PhoenixBlog.Post.Toc

  @mdex_options [
    extension: [table: true, strikethrough: true, autolink: true],
    render: [unsafe: true]
  ]

  defstruct slug: "", title: "", date: Timex.now(), intro: "", content: "", props: %{}

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
      content: build_content(markdown, props),
      props: props
    }
  end

  defp build_content(markdown, props) do
    html =
      markdown
      |> MDEx.parse_document!(@mdex_options)
      |> MDEx.traverse_and_update(&apply_code_language_prefix/1)
      |> add_toc(props)
      |> MDEx.to_html!(@mdex_options)

    ~s(<div class="post-container">#{html}</div>)
  end

  defp add_toc(doc, props)
  defp add_toc(doc, %{"add_toc" => true}), do: Toc.setup(doc, @mdex_options)
  defp add_toc(doc, _props), do: doc

  defp file_to_slug(file) do
    file
    |> String.split("/")
    |> List.last()
    |> String.replace(~r/\.md$/, "")
  end

  defp apply_code_language_prefix(%MDEx.CodeBlock{info: info, literal: literal} = block) do
    case String.split(info) do
      [language | _] ->
        class = "language-#{language}"

        %MDEx.HtmlBlock{
          literal:
            ~s(<pre class="#{class}"><code class="#{class}">#{Plug.HTML.html_escape(literal)}</code></pre>\n)
        }

      [] ->
        block
    end
  end

  defp apply_code_language_prefix(%MDEx.Code{literal: literal}) do
    %MDEx.HtmlInline{literal: ~s(<code class="inline">#{Plug.HTML.html_escape(literal)}</code>)}
  end

  defp apply_code_language_prefix(node), do: node
end
