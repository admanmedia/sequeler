
defmodule Sequeler.Controller do
  alias Plug.Conn

  @doc """
    Actually perform MySQL query and return JSON response.
  """
  def query(conn) do
    result = :emysql.execute(:db,conn.params["sql"])

    json = case result do
      {:result_packet, _, _fields, data, _} -> Jazz.encode! data
      _ -> "[]"
    end

    conn
    |> Conn.put_resp_header("content-type", "application/json")
    |> Conn.resp(200, json)
  end
end
