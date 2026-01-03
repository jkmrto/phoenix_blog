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

  def collapse_information_component(assigns) do
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
        <%= Phoenix.HTML.raw(Enum.map(@desc_paragraphs, fn p -> "<p> #{p} </p>" end)) %>
      </div>
    </div>
    """
  end

  def skill_image(assigns) do
    ~H"""
    <a href={link_for_skill(@skill)}>
      <div class="d-flex flex-row" style="font-size: 2.0rem">
        <%= img_tag(route_to_skill_img(@skill), style: "width: 30px; height: 30px; display: inline") %>
        <l class="mx-3"><%= @skill %></l>
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

  def remote(assigns) do
    ~H"""
    <div>
      <div class="experience-intro-container">
        <a href="https://remote.com//">
          <img class="resume-company-img" src="/images/remote.png" />
        </a>

        <div class="experience-header-container">
          <p class="experience-title">Remote- <em class="role"> Backend Engineer</em></p>

          <div class="entry-header">
            <p class="resume-date">Jul 2023 - Currently</p>

            <p class="resume-badges-container">
              <Badges.elixir />
              <Badges.postgresql />
              <Badges.docker />
              <Badges.kubernetes />
              <Badges.phoenix />
            </p>
          </div>
        </div>
      </div>

      <.collapse_information_component
        id="more-information-remote"
        desc_paragraphs={[
          "I joined Remote as Backend Engineer in the fintech area of the company, in charge of processing the expenses from payrolls and other company costs, applying the appropiate FX rates and building up the invoices.",
          "Some of the main projects I work on:",
          "- <b>Standarisation of the FX Rates</b>: Migrate from a previous on the flight approach to select FX Rates to an standarised approach where the same FX Rates are applied in prefunding and in reconciliation billing cycles. It includes other capabilities like traceability for FX Rates and FX spreads.",
          "- <b>Migration for a new external billing provider</b>: As part of the migration to a new billing provider, we standarised the approach for creating invoiceable components from different costs. I contributed migrating a big part of the costs to the new approach, untangling how the legacy works in some cases to correctly create the new costs components."
        ]}
      />
    </div>
    """
  end

  def equalture(assigns) do
    ~H"""
    <div>
      <div class="experience-intro-container">
        <a href="https://www.equalture.com/">
          <img class="resume-company-img" src="/images/equalture.jpeg" />
        </a>

        <div class="experience-header-container">
          <p class="experience-title">Equalture - <em class="role"> Software Developer</em></p>

          <div class="entry-header">
            <p class="resume-date">Sep 2021 - Currently</p>

            <p class="resume-badges-container">
              <Badges.elixir />
              <Badges.phoenix_live_view />
              <Badges.mysql />
              <Badges.postgresql />
              <Badges.docker />
              <Badges.kubernetes />
              <Badges.helm />
              <Badges.google_cloud />
              <Badges.phoenix />
            </p>
          </div>
        </div>
      </div>

      <.collapse_information_component
        id="more-information-equalture"
        desc_paragraphs={[
          "After almost two years working with Go, I missed working with Elixir, especially trying out some new features like LiveView. That was one of the motivations for joining Equalture, along together the great experience of using their own games based assessments during the hiring process.",
          "<strong>Equalture is a startup that provides a biased free hiring platform</strong>. Based on games assessments, this platform analyzes teams and candidates, providing valuable insights about the best candidates for any team.",
          "As an Elixir developer, <strong>I participated in the development of new features both in the frontend and in the backend side of the product. Mainly working with Elixir and Phoenix LiveView, the project also involves working with other technologies like Kubernetes and Google Cloud. </strong>",
          "Some of my tasks included:",
          "- Develop a new API for external clients, proposing and maintaing Open API docs.",
          "- Develop a 2FA approach for the wep app.",
          "- Develop a real time filter system for candidates. This ends up in a multi-dimensional dynamic query",
          "- Lead the devops area in the company. Proposing improvements and applying them on the Kubernetes cluster like the usage of default-backend for maintenance or supporting the upgrade of some components like cert-manager or Nginx ingress",
          "- Support and mentor other team members. Leading up a team of three devs"
        ]}
      />
    </div>
    """
  end

  def paack(assigns) do
    ~H"""
    <div class="experience-all-container">
      <div class="experience-intro-container">
        <img class="resume-company-img" src="/images/paack.png" width="140px" height="140px" />

        <div class="experience-header-container">
          <p class="experience-title">Paack - <em class="role">Backend Developer</em></p>

          <div class="entry-header">
            <p class="date" style="margin-bottom:5px">March 2020 - Sep 2021</p>

            <div>
              <p class="resume-badges-container">
                <Badges.go />
                <Badges.docker />
                <Badges.rabbitmq />
                <Badges.postgresql />
                <Badges.kubernetes />
                <Badges.python />
                <Badges.helm />
                <Badges.graphql />
                <Badges.google_cloud />
              </p>
            </div>
          </div>
        </div>
      </div>

      <.collapse_information_component
        id="more-information-paack"
        desc_paragraphs={[
          "For almost all my career I had been working mainly with Elixir and his ecosystem. I felt I needed to try some other technologies, that is why I decided to make a move to Go.",
          "<strong>Paack is a startup focused on logistics</strong>. When I entered the company they were trying to expand their backend using Go. <strong>This experience allowed me to get a deeper knowledge of SOLID principles, hexagonal architecture and how to approach 24/7 systems without OTP. </strong>",
          "I designed and built from the scratch with the help of another workmate the new routing platform. This microservice is in charge of comunicating with the external routing providers, offering a clear interface for internal microservices, hidding the complexity of each routing provider for the rest of the platform."
        ]}
      />
    </div>
    """
  end

  def derivco(assigns) do
    ~H"""
    <div class="experience-all-container">
      <div class="experience-intro-container">
        <img class="resume-company-img" src="/images/derivco.png" />

        <div class="experience-header-container">
          <p class="experience-title">Derivco - <em class="role">Software Developer</em></p>

          <div class="entry-header">
            <p class="resume-date">May 2019 - February 2020</p>

            <p class="resume-badges-container">
              <Badges.elixir />
              <Badges.ruby />
              <Badges.go />
              <Badges.rabbitmq />
              <Badges.postgresql />
              <Badges.ansible />
              <Badges.ansible />
              <Badges.azure />
            </p>
          </div>
        </div>
      </div>

      <.collapse_information_component
        id="more-information-derivco"
        desc_paragraphs={[
          "After being working for a tiny startup for almost three years I wanted to try some kind of bigger company and continue working with Elixir. That's why I decided to join Derivco which is a company with more than 4.000 workers around the world is the software provider for Betway, one of the bigger sportbook around the world.",
          "<strong>At Derivco I was part of the Core team in charge of developing and maintain several service in Ruby, Elixir and Go.</strong>",
          "One of the main project I worked on was in the migration of a microrservice from Ruby to Elixir. This service was in charge of forwarding changes in the core database, using triggers for listening changes and RabbitMQ as messages broker."
        ]}
      />
    </div>
    """
  end

  def palmtree(assigns) do
    ~H"""
    <div class="experience-all-container">
      <div class="experience-intro-container">
        <img class="resume-company-img" src="/images/palmtree.png" />

        <div class="experience-header-container">
          <p class="experience-title">
            Palmtree Statistics - <em class="role">Software Developer</em>
          </p>
          <div class="entry-header">
            <p class="resume-date">September 2016 - April 2019</p>
            <div class=" resume-badges-container">
              <Badges.elixir />
              <Badges.python />
              <Badges.rabbitmq />
              <Badges.postgresql />
              <Badges.mongodb />
              <Badges.docker />
              <Badges.kubernetes />
              <Badges.javascript />
              <Badges.elm />
            </div>
          </div>
        </div>
      </div>

      <.collapse_information_component
        id="more-information-palmtree"
        desc_paragraphs={[
          "This was my first working experience and a relevant personal step that had allowed me to discover an enyojable professional path. Palmtree Statistics was a tiny startup focused on the development of tools for analysis realtime sports data.",
          "I started at Palmtree as an Intern getting contracted at the end the training period. As intern, I learned about the principles of clean code and professional software development. I worked on the development of a testing environment with Python and Docker."
        ]}
      />
    </div>
    """
  end

  def grado_teleco(assigns) do
    ~H"""
    <div class="experience-all-container">
      <div class="experience-intro-container">
        <img class="resume-studies-img" src="/images/ugr.jpg" />

        <div class="experience-header-container">
          <p class="education-title">Degree In Telecommunication Engineering</p>
          <p class="education-location">Granada - Spain</p>
          <p class="resume-date">September 2011 - September 2015</p>
        </div>
      </div>

      <.collapse_information_component
        id="more-information-ugr"
        desc_paragraphs={[
          "The telecommunications engineering degree is one the most prestigious engineering degrees in Spain. With a solid base in physics and mathematics, this degree covers electronics to networking design. Through my stage as a student, I learned a solid knowledge about how electronics systems work, from the basics to how to transmit information through air or wire interfaces.",
          "As <strong>final degree project</strong>, I contributed to an investigation platform called TIE (Traffic indentifications engine) . The objective of this platform is to compare different algorithms for network traffic classification. In my case, I built an algorithm that classifies the traffic based on the size of the packages. A clustering algorithm called K-means was applied built in C."
        ]}
      />
    </div>
    """
  end

  def master_teleco(assigns) do
    ~H"""
    <div class="experience-all-container">
      <div class="experience-intro-container">
        <a href="https://www.uma.es/">
          <img class="resume-studies-img" src="/images/uma.png" />
        </a>

        <div class="experience-header-container">
          <a
            class="education-title"
            href="https://www.uma.es/master-universitario-en-ingenieria-de-telecomunicacion?set_language=en"
          >
            Master In Telecommunication Engineering
          </a>

          <p class="education-location">Malaga - Spain</p>
          <p class="resume-date">September 2015 - September 2017</p>
        </div>
      </div>

      <.collapse_information_component
        id="more-information-uma"
        desc_paragraphs={[
          "This master is the final step for the telecommunication engineering path in Spain. It includes some topics such as optical communications, microelectronics and sotware defined networks.",
          "As <strong> final master project </strong>, I implemented an artificial neural network system for the premature detection of Alzheimer. The system was implemented in Python, using some libraries such as TensorFlow and NumPy.",
          "The neural network was based on the variational autoencoder. The main idea was being able to reduce the high number of dimensions of an MRI or PET image, to a few dimensions. This will allow the algorithm to capture the intrinsic characteristics to detect the disease."
        ]}
      />
    </div>
    """
  end
end
