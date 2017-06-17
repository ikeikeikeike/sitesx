defmodule Sitesx.Plug do
  import Plug.Conn

  alias Sitesx.{Q, Config}

  def init(opts), do: opts
  def call(conn, _opts) do
    with qs when not is_nil(qs) <- Q.findsite(conn),
         md when not is_nil(md) <- Config.repo().one(qs)
    do
      put_private conn, :sitesx_model, md
    else _ ->
      put_private conn, :sitesx_model, nil
    end
  end
end
