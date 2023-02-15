defmodule PhoenixBlogWeb.ResumeView do
  use Phoenix.View,
    namespace: PhoenixBlogWeb.Resume,
    root: "lib/phoenix_blog_web/templates/resume",
    pattern: "**/*"

  import Phoenix.Component
  import Phoenix.HTML
  import Phoenix.HTML.Tag

  alias PhoenixBlogWeb.Router.Helpers, as: Routes
  alias PhoenixBlogWeb.Components.Badges

  @skill_to_image %{
    "Elixir" => "elixir.png",
    "Phoenix" => "phoenix.png",
    "Go" => "go.png",
    "Docker" => "docker.png",
    "Kubernetes" => "kubernetes.png",
    "RabbitMQ" => "rabbitmq.jpg"
  }

  @skill_to_link %{
    "Elixir" => "https://elixir-lang.org/",
    "Phoenix" => "https://www.phoenixframework.org/",
    "Go" => "https://golang.org/",
    "Docker" => "https://www.docker.com/",
    "Kubernetes" => "https://kubernetes.io/",
    "RabbitMQ" => "https://www.rabbitmq.com/"
  }

  def collapse_information_component(id, desc_paragraphs) do
    assigns = %{id: id, desc_paragraphs: desc_paragraphs}

    ~H"""
    <div class="more-information-container">
      <div
        class="more-information-link collapsed px-4"
        data-toggle="collapse"
        data-target={"##{@id}"}
        aria-expanded="false"
      >
        <p style="font-weight: bold">More Information</p>
        <i class="fa fa-angle-down" aria-hidden="true" style="font-size: 2.5rem"></i>
      </div>

      <div id={@id} class="mx-3 collapse">
        <%= raw(Enum.map(@desc_paragraphs, fn p -> "<p> #{p} </p>" end)) %>
      </div>
    </div>
    """
  end

  def skill_image(skill) do
    assigns = %{skill: skill}

    ~H"""
    <a href={link_for_skill(@skill)}>
      <div class="d-flex flex-row" style="font-size: 2.0rem">
        <%= img_tag(route_to_skill_img(skill), style: "width: 30px; height: 30px; display: inline") %>
        <l class="mx-3"><%= skill %></l>
      </div>
    </a>
    """
  end

  defp route_to_skill_img(skill) do
    path = "/images/resume/#{Map.get(@skill_to_image, skill)}"
    Routes.static_path(PhoenixBlogWeb.Endpoint, path)
  end

  defp link_for_skill(skill) do
    Map.get(@skill_to_link, skill)
  end
end
