defmodule Sequeler.Query do
  import Plug.Conn

  @moduledoc """
    Query controller code
  """

  @doc """
    Actually perform MySQL query and return JSON response.

  """
  def query(conn) do

    json = case :emysql.execute(:db,"") do
      {:result_packet, num, _, _, data} -> Jazz.encode! data
      _ -> "{}"
    end

    resp(conn, 200, json)
  end

end
