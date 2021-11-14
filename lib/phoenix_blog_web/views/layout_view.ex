defmodule PhoenixBlogWeb.LayoutView do
  use PhoenixBlogWeb, :view

  @default_title "jkmrto"

  def title(%{title: title}), do: "#{title} - #{@default_title}"
  def title(_assigns), do: @default_title
end
