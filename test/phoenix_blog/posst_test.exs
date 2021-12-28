defmodule PhoenixBlog.PostTest do
  use ExUnit.Case

  alias PhoenixBlog.Post

  test "build_ul_node_with_list" do
    node = [{"h3", "hola wtf 2"}, {"h3", "hola wtf 1"}]

    assert Post.build_ul_node_with_list(node) ==
             {"ul", [],
              [
                {"li", [],
                 {"a", [{"class", "toc"}, {"href", "#hola-wtf-2"}], ["hola-wtf-2"], %{}}, %{}},
                {"li", [],
                 {"a", [{"class", "toc"}, {"href", "#hola-wtf-1"}], ["hola-wtf-1"], %{}}, %{}}
              ], %{}}
  end

  test "build_li_with_sublist" do
    input = {"h2", "hola wtf", [{"h3", "hola wtf 1"}]}

    assert Post.build_li_with_sublist(input) == [
             {"li", [], {"a", [{"class", "toc"}, {"href", "#hola-wtf"}], ["hola-wtf"], %{}}, %{}},
             {"ul", [],
              [
                {"li", [],
                 {"a", [{"class", "toc"}, {"href", "#hola-wtf-1"}], ["hola-wtf-1"], %{}}, %{}}
              ], %{}}
           ]
  end

  test "apply_languague_code_preffix" do
    code_snippet = "
    ```elixir
    example code
    ```
    "

    File.read!("test/fixtures/code_post.md")
    |> IO.inspect()

    {:ok, ast, []} = EarmarkParser.as_ast(code_snippet)
    Post.apply_languague_code_preffix(ast)
  end

  test "get text from title" do
    hey =
      {"h2", [],
       [
         "Enable ",
         {"code", [{"class", "inline"}], ["eex"], %{}},
         " parser for ",
         {"code", [{"class", "inline"}], ["heex"], %{}},
         " files."
       ], %{}}

    IO.inspect(hey)

    assert true
  end
end
