defmodule PhoenixBlogWeb.ContactHTML do
  use Phoenix.Component
  use PhoenixHTMLHelpers

  alias PhoenixBlogWeb.Router.Helpers, as: Routes

  embed_templates "contact_html/*"
end
