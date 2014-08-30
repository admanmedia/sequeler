defmodule CipherTest do
  use ExUnit.Case

  test "the whole cipher stack" do
    s = Jazz.encode! %{:hola => "qué tal ｸｿ"}
    key = Cipher.generate_key "testingphrasesforencryption"
    iv = Cipher.generate_iv "testingphrasesforencryption"
    assert s == s |> Cipher.encrypt(key, iv) |> Cipher.decrypt(key, iv)
  end
end
