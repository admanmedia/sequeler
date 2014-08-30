
defmodule Cipher do

  @moduledoc """
    Helpers to encrypt and decrypt data.
  """

  @doc """
    Returns encrypted string containing given `data` string, using given `key`
    and `iv`.
    Suitable `key` and `iv` can be generated with `generate_key/1`
    and `generate_iv/1`.
  """
  def encrypt(data, key, iv) do
    encrypted = :crypto.block_encrypt :aes_cbc128, key, iv, pad(data)
    encrypted |> Base.encode64 |> URI.encode_www_form
  end

  @doc """
    Returns decrypted string contained in given `crypted` string, using given
    `key` and `iv`.
    Suitable `key` and `iv` can be generated with `generate_key/1`
    and `generate_iv/1`.
  """
  def decrypt(crypted, key, iv) do
    {:ok, decoded} = crypted |> URI.decode_www_form |> Base.decode64
    :crypto.block_decrypt(:aes_cbc128, key, iv, decoded) |> depad
  end

  @doc "Generates a suitable key for encryption based on given `phrase`"
  def generate_key(phrase) do
    :crypto.hash(:sha, phrase) |> hexdigest |> String.slice(0,16)
  end

  @doc "Generates a suitable iv for encryption based on given `phrase`"
  def generate_iv(phrase), do: phrase |> String.slice(0,16)

  @doc "Gets an usable string from a binary crypto hash"
  def hexdigest(binary) do
    :lists.flatten(for b <- :erlang.binary_to_list(binary),
        do: :io_lib.format("~2.16.0B", [b]))
    |> :string.to_lower
    |> List.to_string
  end

  @doc """
    Pad given string until its length is divisible by 16.
    It uses PKCS#7 padding.
  """
  def pad(str) do
    len = byte_size(str)
    utfs = len - String.length(str) # UTF chars are 2byte, ljust counts only 1
    pad_len = 16 - rem(len, 16) - utfs
    String.ljust(str, len + pad_len, pad_len) # PKCS#7 padding
  end

  @doc "Remove PKCS#7 padding from given string."
  def depad(str) do
    <<last>> = String.last str
    String.rstrip str, last
  end

end
