defmodule Devtools do

  @doc """
    Get OTP applications that should be started, including this one.
    Format: `[app: version, ...]`
  """
  def get_apps do
    for {app,_,vsn} <- :application.which_applications(), do: {app,vsn}, into: []
  end

  @doc """
    Get external libraries that should be only loaded (i.e. external
    dependencies that are not OTP applications).
    Format: `[app: version, ...]`
  """
  def get_libs do
    apps = get_apps
    deps = Sequeler.Mixfile.project[:deps] |> Keyword.keys
            |> Enum.filter(fn(d) -> apps[d] == nil end)

    for d <- deps, into: [] do
      mod = d |> to_string |> String.capitalize |> String.to_existing_atom
      vsn = Module.concat([Elixir,mod,Mixfile]).project[:version]
      {d,vsn}
    end
  end

end
