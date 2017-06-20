defmodule Sitesx.Plug do
  @moduledoc """
  Stores Sitesx model into private on Plug struct.

  A `Sitesx.Plug` module extracts domain information from request URL or `sub` queryparameter.

  ## Plug in Router

      defmodule MyApp.Router do
        use MyApp.Web, :router

        pipeline :browser do
          plug :accepts, ["html"]
          plug :fetch_session
          plug :fetch_flash
          plug :protect_from_forgery
          plug :put_secure_browser_headers

          plug Sitesx.Plug
        end
      end

  ## Plug in Controller

      defmodule MyApp.MyController do
        use MyApp.Web, :controller

        plug Sitesx.Plug
      end

  """
  import Plug.Conn

  alias Sitesx.{Q, App}

  def init(opts), do: opts
  def call(conn, _opts) do
    with qs when not is_nil(qs) <- Q.site(conn),
         md when not is_nil(md) <- App.repo().one(qs)
    do
      put_private conn, :sitesx_model, md
    else _ ->
      put_private conn, :sitesx_model, nil
    end
  end
end
