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
    conn
    |> put_flash(:error, "Please: complete the captcha")
    |> render_index()
  end

  def create(conn = %{params: params}, _) do
    with {:ok, _response} <- Recaptcha.verify(params["g-recaptcha-response"]),
         {:ok, _info} <-
           PhoenixBlog.Email.email(
             params["name"],
             params["subject"],
             params["email"],
             params["message"]
           ) do
      conn
      |> put_flash(:info, "Email correctly sent")
      |> render_index()
    else
      {:error, errors} ->
        Logger.error("#{inspect(errors)}")

        conn
        |> put_flash(:error, "Something went wrong")
        |> render_index()
    end
  end

  defp render_index(conn) do
    conn
    |> assign(:title, "Contact")
    |> render("index.html")
  end
end
