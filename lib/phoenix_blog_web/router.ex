defmodule PhoenixBlogWeb.Router do
  use PhoenixBlogWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, false
    plug :put_root_layout, {PhoenixBlogWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixBlogWeb do
    pipe_through :browser

    get "/resume", ResumeController, :index

    get "/contact", ContactController, :index
    post "/contact", ContactController, :create
    
    live "/reading_list", Live.ReadingListLive
    live "/reading_list/:book/notes", Live.ReadingNotesLive 

    get "/posts/:slug", PostController, :show
    get "/posts", PostController, :index
    get "/", LandingController, :index
  end
end
