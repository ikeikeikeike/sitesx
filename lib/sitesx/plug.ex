defmodule Sitesx.Plug do
  import Plug.Conn

  @before_compile Sitesx.Config

  def init(opts), do: opts
  def call(conn, opts) do
    with qs when not is_nil(qs) <- Sitesx.Q.findsite(conn),
         %@app.Site{} = site    <- @app.Repo.one(qs)
    do
           put_private conn, :sitesx_model, site
    else
      _ -> put_private conn, :sitesx_model, nil
    end
  end
end
