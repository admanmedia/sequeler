defmodule CipherTest do
  use ExUnit.Case, async: true
  alias Cipher, as: C
  import TestHelper, only: [k: 0,i: 0]

  test "the whole encrypt/decrypt stack" do
    s = Jazz.encode! %{:hola => "qué tal ｸｿ"}
    assert s == s |> C.encrypt(k,i) |> C.decrypt(k,i)
  end

  test "url signature" do
    # ok with regular urls
    url = "/blab/bla"
    assert url |> C.sign_url(k,i) |> C.validate_signed_url(k,i)
    url = "/blab/bla?sdfgsdf=dfgsd"
    assert url |> C.sign_url(k,i) |> C.validate_signed_url(k,i)

    # not signed fails
    url = "/blab/bla"
    refute C.validate_signed_url(url,k,i)

    # bad signature fails
    signed = url <> "?signature=badhash"
    refute C.validate_signed_url(signed,k,i)
  end

end
