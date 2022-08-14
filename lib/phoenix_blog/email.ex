defmodule PhoenixBlog.Mailer do
  use Swoosh.Mailer,
    otp_app: :phoenix_blog
end

defmodule PhoenixBlog.Email do
  import Swoosh.Email

  def email(name, subject, email, message) do
    new()
    |> from("jkmrto.blog@gmail.com")
    |> to("jkmrto@gmail.com")
    |> subject(subject)
    |> text_body("[" <> email <> "] " <> name <> "\n\n" <> message)
    |> PhoenixBlog.Mailer.deliver()
  end
end
