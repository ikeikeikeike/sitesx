defmodule Sitesx.Plug do
  import Plug.Conn

  alias Sitesx.Q

  @before_compile Sitesx.Config

  def init(opts), do: opts
  def call(conn, opts) do
    with qs when not is_nil(qs) <- Q.findsite(conn),
         md when not is_nil(md) <- xrepo().one(qs)
    do
           put_private conn, :sitesx_model, md
    else
      _ -> put_private conn, :sitesx_model, nil
    end
  end
end
