alias Sequeler.Helpers, as: H

defmodule Sequeler.Controller do
  alias Plug.Conn

  @doc """
    Actually perform MySQL query and return JSON response.
  """
  def query(conn) do
    json = H.query(:db,conn.params["sql"]) |> Jazz.encode!

    conn
    |> Conn.put_resp_header("content-type", "application/json")
    |> Conn.resp(200, json)
  end
end
