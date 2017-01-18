defmodule Sitesx.Plug do
  import Plug.Conn

  @before_compile Sitesx.Config

  def init(opts), do: opts
  def call(conn, opts) do
    site = Module.concat cfg_app, Site

    with qs when not is_nil(qs) <- Sitesx.Q.findsite(conn),
         struct(site) = model   <- Module.concat(cfg_app, Repo).one(qs)
    do
           put_private conn, :sitesx_model, model
    else
      _ -> put_private conn, :sitesx_model, nil
    end
  end
end
