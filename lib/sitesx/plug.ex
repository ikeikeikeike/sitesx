defmodule Sitesx.Plug do
  import Plug.Conn

  @before_compile Sitesx.Config

  def init(opts), do: opts
  def call(conn, opts) do
    site = concat Site

    with qs when not is_nil(qs) <- Sitesx.Q.findsite(conn),
         md when not is_nil(md) <- concat(Repo).one(qs)
    do
           put_private conn, :sitesx_model, md
    else
      _ -> put_private conn, :sitesx_model, nil
    end
  end
end
