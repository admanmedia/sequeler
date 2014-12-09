defmodule Sequeler.Mixfile do
  use Mix.Project

  def project do
    [app: :sequeler,
     version: get_version_number,
     elixir: "~> 1.0.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :cowboy, :plug, :emysql],
     included_applications: [:jazz, :cipher, :harakiri],
     mod: {Sequeler, []}]
  end

  # Type `mix help deps` for more examples and options
  defp deps do
    [ {:cowboy, "~> 1.0.0"}, # plug needs this to be listed before...
      {:plug, "0.8.3"},
      {:emysql, github: "Eonblast/Emysql"},
      {:jazz, github: "meh/jazz"},
      {:cipher, github: "rubencaro/cipher"},
      {:harakiri, github: "elpulgardelpanda/harakiri"}]
  end

  defp get_version_number do
    commit = :os.cmd('git rev-parse --short HEAD') |> to_string |> String.rstrip(?\n)
    {{y, m, d}, {_, _, _}} = :calendar.now_to_universal_time(:os.timestamp())
    v = "1.0.0+#{y}#{m}#{d}_#{commit}"
    if Mix.env == :dev, do: v = v <> "dev"
    v
  end
end
