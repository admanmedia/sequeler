
defmodule TestHelper do
  use Plug.Test
  alias Cipher, as: C

  # handy to have them around
  def k, do: C.generate_key "testingphrasesforencryption"
  def i, do: C.generate_iv "testingphrasesforencryption"

  @doc "Performs GET request against given plug. Returns Conn."
  def get(url, plug, opts) do
    conn = conn(:get, url)
    plug.call(conn, opts)
  end
end

ExUnit.start()
