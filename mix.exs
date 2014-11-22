defmodule Sequeler.Mixfile do
  use Mix.Project

  def project do
    [app: :sequeler,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :cowboy, :plug, :emysql],
     included_applications: [:jazz, :cipher],
     mod: {Sequeler, []}]
  end

  # Type `mix help deps` for more examples and options
  defp deps do
    [ {:cowboy, "~> 1.0.0"}, # plug needs this to be listed before...
      {:plug, "0.8.0"},
      {:emysql, github: "Eonblast/Emysql"},
      {:jazz, github: "meh/jazz"},
      {:cipher, github: "rubencaro/cipher"},
      {:exrm, "~> 0.14.12"}]
  end
end
