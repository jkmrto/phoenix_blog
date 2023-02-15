defmodule PhoenixBlogWeb.Components.Badges do
  use Phoenix.Component

  def ansible(assigns),
    do: badge(%{text: "Ansible", link: "https://www.ansible.com/", color: "#000"})

  def angular(assigns),
    do: badge(%{text: "Angular", link: "https://angular.io/", color: "#D40027"})

  def aws(assigns),
    do: badge(%{text: "AWS", link: "https://aws.amazon.com/", color: "#FF8F00"})

  def azure(assigns),
    do: badge(%{text: "Azure", link: "https://azure.microsoft.com", color: "#006EC6"})

  def docker(assigns),
    do: badge(%{text: "Docker", link: "https://www.docker.com/", color: "#009BF2"})

  def ecto(assigns),
    do: badge(%{text: "Ecto", link: "https://hexdocs.pm/ecto/Ecto.html", color: "#77BF44"})

  def elixir(assigns),
    do: badge(%{text: "Elixir", link: "https://elixir-lang.org/", color: "#7C57AA"})

  def elm(assigns),
    do: badge(%{text: "Elm", link: "https://elm-lang.org/", color: "#0094DE"})

  def go(assigns),
    do: badge(%{text: "Go", link: "https://golang.org/", color: "#61D7ED"})

  def google_cloud(assigns),
    do: badge(%{text: "Google Cloud", link: "https://cloud.google.com/", color: "#B8002F"})

  def graphql(assigns),
    do: badge(%{text: "GraphQL", link: "https://graphql.org/", color: "#2CA527"})

  def helm(assigns),
    do: badge(%{text: "Helm", link: "https://helm.sh/", color: "#FE8E00"})

  def java(assigns),
    do: badge(%{text: "Java", link: "https://www.java.com", color: "#246AEE"})

  def javascript(assigns),
    do:
      badge(%{
        text: "Javascript",
        link: "https://en.wikipedia.org/wiki/JavaScript",
        color: "#FE8E00"
      })

  def kafka(assigns),
    do: badge(%{text: "Kafka", link: "https://kafka.apache.org/", color: "#0000"})

  def kubernetes(assigns),
    do: badge(%{text: "Kubernetes", link: "https://kubernetes.io/", color: "#246AEE"})

  def mnesia(assigns),
    do: badge(%{text: "Mnesia", link: "https://erlang.org/doc/man/mnesia.html", color: "#B8002F"})

  def mnesia(assigns),
    do: badge(%{text: "Mnesia", link: "https://erlang.org/doc/man/mnesia.html", color: "#B8002F"})

  def mongodb(assigns),
    do: badge(%{text: "MongoDB", link: "https://www.mongodb.com/", color: "#00AE46"})

  def mysql(assigns),
    do: badge(%{text: "Mysql", link: "https://www.mysql.com/", color: "#00AE46"})

  def neovim(assigns),
    do: badge(%{text: "NeoVim", link: "https://neovim.io/", color: "#2CA527"})

  def phoenix(assigns),
    do: badge(%{text: "Phoenix", link: "https://www.phoenixframework.org/", color: "#FF711A"})

  def postgresql(_assigns),
    do: badge(%{text: "PostgreSQL", link: "https://www.postgresql.org/", color: "#1E6591"})

  def python(assigns),
    do: badge(%{text: "Python", link: "https://www.python.org/", color: "#1D77B0"})

  def rabbitmq(assigns),
    do: badge(%{text: "RabbitMQ", link: "https://www.rabbitmq.com/", color: "#FF5900"})

  def rust(assigns),
    do: badge(%{text: "Rust", link: "https://www.rust-lang.org/", color: "#000000"})

  def ruby(assigns),
    do: badge(%{text: "Ruby", link: "https://www.ruby-lang.org/en/", color: "#000000"})

  def terraform(assigns),
    do: badge(%{text: "Terraform", link: "https://www.terraform.io/", color: "#6D31ED"})

  def phoenix_live_view(_assigns),
    do:
      badge(%{
        text: "Phoenix LiveView",
        link: "https://github.com/phoenixframework/phoenix_live_view",
        color: "#000000"
      })

  defp badge(assigns) do
    ~H"""
    <a href={@link} target="_blank" class="badge" style={"background-color: #{@color}"}>
      <%= @text %>
    </a>
    """
  end
end
