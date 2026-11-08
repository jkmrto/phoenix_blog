defmodule PhoenixBlogWeb.Components.ResumeComponents do
  use Phoenix.Component
  use PhoenixHTMLHelpers

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

  attr :logo, :string, required: true
  attr :logo_alt, :string, required: true
  attr :link, :string, default: nil
  attr :title, :string, required: true
  attr :role, :string, default: nil
  attr :subtitle, :string, default: nil
  attr :start_date, Date, required: true
  attr :end_date, Date, default: nil
  attr :show_duration, :boolean, default: true
  attr :highlights, :list, default: []
  attr :details_id, :string, required: true
  attr :details, :list, required: true
  slot :badges

  def timeline_entry(assigns) do
    ~H"""
    <div class="timeline-entry">
      <a :if={@link} href={@link} class="timeline-logo">
        <img src={@logo} alt={@logo_alt} width="56" height="56" />
      </a>
      <span :if={!@link} class="timeline-logo">
        <img src={@logo} alt={@logo_alt} width="56" height="56" />
      </span>

      <div class="timeline-content">
        <p class="timeline-title">
          <strong>{@title}</strong><span :if={@role}> · <em>{@role}</em></span>
        </p>
        <p :if={@subtitle} class="timeline-subtitle">{@subtitle}</p>
        <p class="timeline-date">
          {format_month(@start_date)} – {if @end_date, do: format_month(@end_date), else: "Present"}
          <span :if={@show_duration} class="timeline-duration">
            · {duration(@start_date, @end_date)}
          </span>
        </p>
        <ul :if={@highlights != []} class="timeline-highlights">
          <li :for={highlight <- @highlights}>{highlight}</li>
        </ul>
        <div :if={@badges != []} class="resume-badges-container">{render_slot(@badges)}</div>
        <.collapse_information_component id={@details_id} desc_paragraphs={@details} />
      </div>
    </div>
    """
  end

  defp format_month(date), do: Calendar.strftime(date, "%b %Y")

  defp duration(start_date, nil), do: duration(start_date, Date.utc_today())

  defp duration(start_date, end_date) do
    months = (end_date.year - start_date.year) * 12 + end_date.month - start_date.month + 1

    [pluralize(div(months, 12), "yr"), pluralize(rem(months, 12), "mo")]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp pluralize(0, _unit), do: nil
  defp pluralize(1, unit), do: "1 #{unit}"
  defp pluralize(n, unit), do: "#{n} #{unit}s"

  def collapse_information_component(assigns) do
    ~H"""
    <div class="more-information-container">
      <div
        class="more-information-link collapsed"
        data-toggle="collapse"
        data-target={"##{@id}"}
        aria-expanded="false"
      >
        <span>More details</span>
        <i class="fa fa-angle-down" aria-hidden="true"></i>
      </div>

      <div id={@id} class="mx-3 collapse">
        {Phoenix.HTML.raw(Enum.map(@desc_paragraphs, fn p -> "<p> #{p} </p>" end))}
      </div>
    </div>
    """
  end

  def skill_image(assigns) do
    ~H"""
    <a href={link_for_skill(@skill)}>
      <div class="d-flex flex-row" style="font-size: 2.0rem">
        {img_tag(route_to_skill_img(@skill), style: "width: 30px; height: 30px; display: inline")}
        <l class="mx-3">{@skill}</l>
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

  embed_templates "resume_components/*"
end
