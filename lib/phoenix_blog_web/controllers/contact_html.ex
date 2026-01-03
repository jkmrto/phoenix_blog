defmodule PhoenixBlogWeb.ContactHTML do
  use Phoenix.Component
  use PhoenixHTMLHelpers

  import Phoenix.HTML
  import Phoenix.HTML.Form
  alias PhoenixBlogWeb.Router.Helpers, as: Routes

  embed_templates "contact_html/*"
end
