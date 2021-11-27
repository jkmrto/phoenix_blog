defmodule PhoenixBlog.Post.Properties do
  def parse_yaml(yaml) do
    props =
      yaml
      |> String.split("\n")
      |> Enum.map(&String.split(&1, ": "))
      |> Enum.filter(&(length(&1) == 2))
      |> Enum.into(%{}, fn [a, b] -> {a, b} end)

    add_toc = if props["toc"] == "false", do: false, else: true
    Map.put(props, "add_toc", add_toc)
  end
end
