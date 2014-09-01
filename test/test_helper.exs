
defmodule TestHelper do
  use Plug.Test
  alias Cipher, as: C

  # handy to have them around
  def k, do: Application.get_env(:sequeler, :key_phrase) |> C.generate_key
  def i, do: Application.get_env(:sequeler, :iv_phrase) |> C.generate_iv

  @doc "Performs GET request against given plug. Returns Conn."
  def get(url, plug, opts) do
    conn = conn(:get, url)
    plug.call(conn, opts)
  end
end

ExUnit.start()
