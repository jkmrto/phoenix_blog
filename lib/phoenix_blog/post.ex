defmodule PhoenixBlog.Post do
  alias PhoenixBlog.Post
  defstruct slug: "", title: "", date: "", intro: "", content: ""

  def compile(file) do
    {props, content} =
      Path.join(["priv/posts", file])
      |> File.read!()
      |> split()

    %Post{
      slug: file_to_slug(file),
      title: Map.get(props, 'title'),
      date: Timex.parse!(to_string(Map.get(props, 'date')), "{ISOdate}"),
      intro: Map.get(props, 'intro'),
      content: content
    }
  end

  defp file_to_slug(file) do
    String.replace(file, ~r/\.md$/, "")
  end

  defp split(data) do
    [frontmatter, markdown] = String.split(data, ~r/\n-{3,}\n/, parts: 2)

    {parse_yaml(frontmatter),
     Earmark.as_html!(markdown, %Earmark.Options{
       code_class_prefix: "lang-",
       smartypants: false
     })}
  end

  defp parse_yaml(yaml) do
    yaml
    |> :yamerl_constr.string()
    |> hd()
    |> Enum.into(%{})
  end
end
