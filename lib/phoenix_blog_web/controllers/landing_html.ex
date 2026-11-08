defmodule PhoenixBlogWeb.LandingHTML do
  use Phoenix.Component
  use PhoenixHTMLHelpers

  alias PhoenixBlogWeb.Router.Helpers, as: Routes

  def index(assigns) do
    ~H"""
    <div id="landing" class="index-page d-flex flex-column">
      <div class="d-flex flex-column m-auto" style="max-width: 650px;">
        <div class="d-flex flex-wrap">
          <div class="text-wrap">
            <h1>Hi, I'm Juan Carlos 👋</h1>
            <p class="landing-role">Senior Backend Engineer · Elixir &amp; Go</p>
            <p>
              I've spent more than 10 years building backend systems, mostly in Elixir. Today I'm one of the main contributors to the billing area at Remote, where correctness and hard deadlines go hand in hand.
            </p>
            <p>
              I'm especially interested in distributed systems, event-driven architectures and databases, and I enjoy the DevOps side too.
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
          Here I write about things I learn along the way: testing in Elixir, OTP, Docker and Kubernetes.
        </p>

        <div class="landing-actions">
          <.link
            href={Routes.post_path(PhoenixBlogWeb.Endpoint, :index)}
            class="landing-button landing-button-primary"
          >
            Read the posts
          </.link>
          <.link href={Routes.resume_path(PhoenixBlogWeb.Endpoint, :index)} class="landing-button">
            See my resume
          </.link>
          <.link href={Routes.contact_path(PhoenixBlogWeb.Endpoint, :index)} class="landing-button">
            Get in touch
          </.link>
        </div>

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

        <h2 class="landing-latest-title">Latest posts</h2>
        <ul class="landing-latest">
          <li :for={post <- @latest_posts}>
            <.link href={Routes.post_path(PhoenixBlogWeb.Endpoint, :show, post.slug)}>
              {post.title}
            </.link>
            <span class="landing-latest-date">{Timex.format!(post.date, "{Mshort} {YYYY}")}</span>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
