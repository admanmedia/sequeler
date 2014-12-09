
defmodule Sequeler.Harakiri do
  use GenServer

  @moduledoc """
    Start the harakiri loop for the files at given paths in a supervisable
    `GenServer`. If any of the files change, then `Application.stop/1` and
    `Application.unload/1` are called.

    Add it to a supervisor like this:
    `worker( Sequeler.Harakiri, [[ paths: ["file1","file2"] ]] ),`
  """

  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  @doc """
    Init callback, spawn the loop process and return the state
  """
  def init(args) do
    spawn_link fn -> loop(args[:paths]) end
    {:ok, args}
  end

  @doc """
    Perform harakiri if given file is touched. Else keep an infinite loop
    sleeping given msecs each time.
  """
  def loop(paths, sleep_ms \\ 5_000) do
    paths = paths |> Enum.map(fn({path, mtime}) ->
      {path, check_file(path, mtime)}
    end)
    :timer.sleep sleep_ms
    loop paths, sleep_ms
  end

  def check_file(path, previous_mtime \\ nil) do
    new_mtime = File.stat! path
    if previous_mtime and previous_mtime != new_mtime, do: :init.stop
    new_mtime
  end
end
