defmodule PhoenixBlogWeb.LandingHTML do
  use Phoenix.Component
  use PhoenixHTMLHelpers

  alias PhoenixBlogWeb.Router.Helpers, as: Routes

  def index(assigns) do
    ~H"""
    <div id="landing" class="index-page d-flex flex-column">
      <div class="d-flex flex-column m-auto" style="max-width: 650px;">
        <h1>Welcome to my website!</h1>

        <div class="d-flex flex-wrap">
          <div class="text-wrap">
            <p>
              Hi, I'm Juan Carlos, a software developer specialized in the backend. 👋
            </p>
            <p>
              My area of expertise is the backend, and Elixir and Go are the languages I have worked with the most. I also enjoy working on the DevOps side and any challenge that requires learning new things.
            </p>
          </div>
          <div class="image-wrap ms-5">
            <div class="d-flex my-4">
              <img
                src="images/wtf.jpeg"
                alt="Juan Carlos at a mountain lake"
                width="160"
                height="160"
                style="border-radius: 25%"
              />
            </div>
          </div>
        </div>

        <p>
          You can find out more about my background in my <.link href={
            Routes.resume_path(PhoenixBlogWeb.Endpoint, :index)
          }>Resume</.link>.
        </p>

        <p class="mb-1">
          These are some of the areas I am especially interested in:
        </p>
        <ul>
          <li>Distributed systems</li>
          <li>Microservices</li>
          <li>Event-driven systems</li>
          <li>Databases</li>
        </ul>

        <p>
          On this website, you will find some
          <.link href={Routes.post_path(PhoenixBlogWeb.Endpoint, :index)}>posts</.link>
          about topics that caught my attention at some point.
        </p>

        <p>
          Feel free to
          <.link href={Routes.contact_path(PhoenixBlogWeb.Endpoint, :index)}>contact me here</.link>
          or on any social network:
        </p>
        <div id="resume-summary-contact">
          <a href="https://www.github.com/jkmrto" aria-label="GitHub">
            <i class="fab fa-github resume-icon" aria-hidden="true"></i>
          </a>
          <a href="https://www.linkedin.com/in/jkmrto" aria-label="LinkedIn">
            <i class="fab fa-linkedin resume-icon" aria-hidden="true"></i>
          </a>
          <a href="https://twitter.com/jkmrto" aria-label="Twitter">
            <i class="fab fa-twitter resume-icon" aria-hidden="true"></i>
          </a>
        </div>
      </div>
    </div>
    """
  end
end
