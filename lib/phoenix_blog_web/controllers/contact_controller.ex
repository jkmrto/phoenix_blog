defmodule PhoenixBlogWeb.ContactController do
  use PhoenixBlogWeb, :controller

  alias Recaptcha

  def index(conn, _) do
    conn
    |> assign(:title, "Contact")
    |> render("index.html")
  end

  require Logger

  def create(conn = %{params: %{"g-recaptcha-response" => ""}}, _) do
    Logger.warn("trying to send message without captcha")
    render(conn, "index.html")
  end

  def create(conn = %{params: params}, _) do
    case Recaptcha.verify(params["g-recaptcha-response"]) do
      {:ok, _response} ->
        PhoenixBlog.Email.email(
          params["name"],
          params["subject"],
          params["email"],
          params["message"]
        )

      {:error, errors} ->
        Logger.warn("trying to send message without captcha: #{errors}")
    end

    render(conn, "index.html")
  end
end
