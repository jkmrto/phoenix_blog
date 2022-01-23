defmodule PhoenixBlogWeb.ResumeView do
  use Phoenix.View,
    namespace: PhoenixBlogWeb.Resume,
    root: "lib/phoenix_blog_web/templates/resume",
    pattern: "**/*"

  import Phoenix.HTML

  def collapse_information_component(id, desc_paragraphs) do
    ~E"""
    <div class="more-information-container">
    <div
      class="more-information-link collapsed px-4"
      data-toggle="collapse"
      data-target="<%= "#" <> "#{id}" %>"
      aria-expanded="false"
    >
      <p style="font-weight: bold">More Information</p>
      <i class="fa fa-angle-down" aria-hidden="true" style="font-size: 2.5rem"></i>
    </div>

    <div id="<%= "#{id}" %>" class="mx-3 collapse"> 
        <%= raw(Enum.map(desc_paragraphs, fn p -> "<p> #{p} </p>" end)) %>
      </div>
    </div>
    """
  end
end
