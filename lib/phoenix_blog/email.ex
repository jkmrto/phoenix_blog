defmodule PhoenixBlog.Email do
  import Bamboo.Email

  def email(name, subject, email, message) do
    config =
      :phoenix_blog
      |> Confex.get_env(PhoenixBlog.Mailer)
      |> Enum.into(%{})

    mail =
      new_email(
        to: "jkmrto@gmail.com",
        from: "",
        subject: subject,
        text_body: "[" <> email <> "] " <> name <> "\n\n" <> message
      )

    IO.inspect(config)
    PhoenixBlog.Mailer.deliver_now!(mail, config: config)
  end
end

defmodule PhoenixBlog.Mailer do
  use Bamboo.Mailer, otp_app: :phoenix_blog
end
