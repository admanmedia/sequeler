
defmodule Sequeler.Harakiri do
  use GenServer

  @moduledoc """
    Start the harakiri loop for the files at given paths in a supervisable
    `GenServer`. If any of the files change, then `Application.stop/1` and
    `Application.unload/1` are called.

    Add it to a supervisor like this: `worker(Sequeler.Harakiri, []),`
    Then start the self killing loop `Sequeler.Harakiri.start`.
    You can add your files' paths with `Sequeler.Harakiri.watch/1`.
  """

  def start_link, do: GenServer.start_link(__MODULE__, [], name: :sequeler_hk)

  @doc """
    Start Harakiri loop
  """
  def start, do: GenServer.cast(:sequeler_hk, :loop)
  def handle_cast(:loop, _from, paths) do
    loop(paths)
    {:noreply, paths}
  end

  @doc """
    Add given path to Harakiri's paths
  """
  def watch(path), do: GenServer.call(:sequeler_hk, {:watch, path})
  def handle_call({:watch, path}, _from, paths)
    mtime = File.stat! path
    {:reply, :ok, [ paths | {path,mtime} ]}
  end

  @doc """
    Perform harakiri if given file is touched. Else keep an infinite loop
    sleeping given msecs each time.
  """
  def loop(paths, sleep_ms \\ 5_000) do
    paths = paths |> Enum.map(fn({path, mtime}) ->
      {path, check_file(path, mtime)}
    end
    :timer.sleep sleep_ms
    loop paths, sleep_ms
  end

  def check_file(path, previous_mtime \\ nil) do
    new_mtime = File.stat! path
    if previous_mtime and previous_mtime != new_mtime, do: :init.stop
    new_mtime
  end
end