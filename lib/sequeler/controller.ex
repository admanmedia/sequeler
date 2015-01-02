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


  @doc """
    Get last updated_ts on local and remote forrest and compare
  """
  def check_sync_status(conn) do

    table = conn.params["table"]
    sql = "SELECT updated_ts FROM #{table} ORDER BY updated_ts DESC LIMIT 1"

    local = H.query(:db,sql)
    remote = H.query(:db_remote_forrest,sql)

    res = case [local,remote] do
      [[],[]] -> false # empty must fail!
      [x, x] -> true
      _ -> false
    end

    json = Jazz.encode! %{valid: res}

    conn
    |> Conn.put_resp_header("content-type", "application/json")
    |> Conn.resp(200, json)
  end

end
