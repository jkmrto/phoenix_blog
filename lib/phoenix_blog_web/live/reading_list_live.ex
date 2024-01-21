defmodule PhoenixBlogWeb.Live.ReadingListLive do
  use Phoenix.LiveView

  alias PhoenixBlogWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~H"""
    <div>
      <h2>Reading list</h2>
      <div class="my-3 d-flex">
        <img width="150px" height="150px" src="/images/books/design-data-intensive.png" />

        <div class="d-flex flex-column">
          <h4 class="ps-4">Design data Intensive Applciations</h4>
          <span class="ps-4" style="font-size: 15px">Finished &#9989;</span>

          <div class="ps-4" style="font-size: 15px">
            <%= Phoenix.HTML.Link.link(
              "Notes",
              to:
                Routes.live_path(
                  PhoenixBlogWeb.Endpoint,
                  PhoenixBlogWeb.Live.ReadingNotesLive,
                  "cloud-native-devops-with-kubernetes"
                )
            ) %>
          </div>
          <span class="ps-4" style="font-size: 15px">
            Essential introduction to how database are built internally, covering topics like LSM, B-Tree engines or Isolation levels. It includes other topics related to disitributed systems, like data replication and sharding or the CAP theorem. Probably the book where I have spent more time reading
          </span>
        </div>
      </div>

      <div class="my-3 d-flex">
        <img width="150px" height="150px" src="/images/books/design-data-intensive.png" />

        <div class="d-flex flex-column">
          <h4 class="ps-4">Software Engineering at Google</h4>
          <span class="ps-4" style="font-size: 15px">Finished &#9989;</span>

          <div class="ps-4" style="font-size: 15px">
            <%= Phoenix.HTML.Link.link(
              "Notes",
              to:
                Routes.live_path(
                  PhoenixBlogWeb.Endpoint,
                  PhoenixBlogWeb.Live.ReadingNotesLive,
                  "cloud-native-devops-with-kubernetes"
                )
            ) %>
          </div>
          <span class="ps-4" style="font-size: 15px">
            Essential introduction to how database are built internally, covering topics like LSM, B-Tree engines or Isolation levels. It includes other topics related to disitributed systems, like data replication and sharding or the CAP theorem. Probably the book where I have spent more time reading
          </span>
        </div>
      </div>

      <div class="my-5 d-flex">
        <img width="150px" height="150px" src="/images/books/cloud-native-devops.jpg" />

        <div class="d-flex flex-column">
          <h4 class="ps-4">Design data Intensive Applications</h4>
          <span class="ps-4 pb-3" style="font-size: 15px">Finished &#9989;</span>
          <span class="ps-4" style="font-size: 15px">
            Essential introduction to how database are built internally, covering topics like LSM, B-Tree engines or Isolation levels. It includes other topics related to disitributed systems, like data replication and sharding or the CAP theorem. Probably the book where I have spent more time reading.
          </span>
        </div>
      </div>
      <h2>Pending</h2>
      <ul>
        <li>Security containers</li>
        <li>Elixir in Action 3rd edition</li>
        <li>Database Internals: A Deep-Dive Into How Distributed Data Systems Work</li>
        <li>Refactoring: Improving the Design of Existing Code</li>
      </ul>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(title: "my random title")

    {:ok, socket}
  end
end
