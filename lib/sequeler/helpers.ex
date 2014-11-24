require Logger, as: L

defmodule Sequeler.Helpers do

  def to_db_format(value) do
    case value do
      s when is_binary(s) ->
        "'#{s |> String.replace(~r/([\\'"])/,"\\\\\1")}'"
      i when is_integer(i) ->
        "#{i}"
    end
  end

  def query(db,sql) do
    res = :emysql.execute(db,sql)
    case res do
      {:result_packet, _, _, data, _} -> data
      {:ok_packet, _,_,_,_,_,_} -> [] # empty response
      _ ->
        L.warn "Error executing '#{sql}'\nDetails:\n#{inspect res}"
        [sql: sql, error: inspect res]
    end
  end

  def spit(obj, caller) do
    %{file: file, line: line} = caller
    "\n\n#{file}:#{line}\n\n#{inspect obj}\n\n" |> L.debug
  end

end

