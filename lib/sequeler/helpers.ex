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

  @doc """
    Execute the query against the underlying `emysql`.
    Return something serializable to JSON.
  """
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

  def spit(obj, caller \\ nil) do
    loc = case caller do
      %{file: file, line: line} -> "\n\n#{file}:#{line}"
      _ -> ""
    end
    "#{loc}\n\n#{inspect obj}\n\n" |> L.debug
  end

  defmodule FileWatcher do

    @doc """
      Perform harakiri if given file is touched. Else keep an infinite loop
      sleeping given msecs each time.
    """
    def loop(path, previous_mtime \\ nil, sleep_ms \\ 5_000) do
      new_mtime = File.stat! path
      if previous_mtime and previous_mtime != new_mtime do
        :init.stop
      else
        :timer.sleep sleep_ms
        loop path, new_mtime
      end
    end

  end

end

