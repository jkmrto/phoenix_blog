defmodule PhoenixBlogWeb.PostHTML do
  use Phoenix.Component
  use PhoenixHTMLHelpers

  alias PhoenixBlogWeb.Router.Helpers, as: Routes

  embed_templates "post_html/*"
end
