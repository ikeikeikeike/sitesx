defmodule Sitesx.Support.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ~w(html)
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug Sitesx.Plug
  end

  pipeline :api do
    plug :accepts, ~w(json)
  end

  scope "/", Sitesx.Support do
    pipe_through :browser # Use the default browser stack

    get "/", HomeController, :index

    scope "/release" do
      get "/:alias", EntryController, :release
      get "/", EntryController, :release
    end

  end
end
