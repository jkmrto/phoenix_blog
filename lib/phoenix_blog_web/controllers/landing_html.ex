defmodule PhoenixBlogWeb.LandingHTML do
  use Phoenix.Component
  use PhoenixHTMLHelpers

  alias PhoenixBlogWeb.Router.Helpers, as: Routes

  def index(assigns) do
    ~H"""
    <div id="landing" class="index-page d-flex flex-column">
      <div class="d-flex flex-column m-auto" style="max-width: 650px;">
        <h1>Welcome to my website !!</h1>

        <div class="d-flex flex-wrap">
          <div class="text-wrap">
            <p>
              Here Juan Carlos, a Software developer specialized in the Backend Area. 👋
            </p>
            <p>
              My area of expertise is the backend side, while Elixir and Go are the languages I have practiced the most. I also like working on the Devops side, enjoying any challenge that requires learning new stuff.
            </p>
          </div>
          <div class="image-wrap ms-5">
            <div class="d-flex my-4">
              <img src="images/wtf.jpeg" width="160" height="160" style="border-radius: 25%" />
            </div>
          </div>
        </div>

        <p>
          You can check a little more about my background in my <.link href={Routes.resume_path(PhoenixBlogWeb.Endpoint, :index)}>Resume</.link>.
        </p>

        <p class="mb-1">
          These are some of the areas I am specially interested in:
        </p>
        <ul>
          <li>Distributed systems</li>
          <li>Microservices</li>
          <li>Event driven systems</li>
          <li>Databases</li>
        </ul>

        <p>
          On this website, you will find some <.link href={Routes.post_path(PhoenixBlogWeb.Endpoint, :index)}>posts</.link> about some topics that took my attention at some point.
        </p>

        <p>
          Feel free to <.link href={Routes.contact_path(PhoenixBlogWeb.Endpoint, :index)}>contact me here</.link> or at any social network:
        </p>
        <div id="resume-summary-contact">
          <a href="https://www.github.com/jkmrto">
            <i class="fab fa-github resume-icon"></i>
          </a>
          <a href="https://www.linkedin.com/in/jkmrto">
            <i class="fab fa-linkedin resume-icon"></i>
          </a>
          <a href="https://twitter.com/jkmrto">
            <i class="fab fa-twitter resume-icon"></i>
          </a>
        </div>
      </div>
    </div>
    """
  end
end
