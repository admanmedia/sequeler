defmodule CipherTest do
  use ExUnit.Case, async: true
  alias Cipher, as: C

  setup_all do
    # handy to have them around
    key = C.generate_key "testingphrasesforencryption"
    iv = C.generate_iv "testingphrasesforencryption"
    {:ok, k: key, i: iv}
  end

  test "the whole encrypt/decrypt stack", c do
    s = Jazz.encode! %{:hola => "qué tal ｸｿ"}
    assert s == s |> C.encrypt(c[:k], c[:i]) |> C.decrypt(c[:k], c[:i])
  end

  test "url signature", c do
    # ok with regular urls
    url = "/blab/bla"
    assert url |> C.sign_url(c[:k],c[:i]) |> C.validate_signed_url(c[:k],c[:i])
    url = "/blab/bla?sdfgsdf=dfgsd"
    assert url |> C.sign_url(c[:k],c[:i]) |> C.validate_signed_url(c[:k],c[:i])

    # not signed fails
    url = "/blab/bla"
    refute C.validate_signed_url(url, c[:k], c[:i])

    # bad signature fails
    signed = url <> "?signature=badhash"
    refute C.validate_signed_url(url, c[:k], c[:i])
  end

end
