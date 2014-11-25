defmodule Devtools do

  @doc """
    Get OTP applications that should be started, including this one.
    Format: `[app: version, ...]`
  """
  def get_apps do
    apps = for {app,_,vsn} <- :application.which_applications(), do: {app,vsn}, into: []
    Enum.concat(apps,[sasl: '2.4.1'])
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
      vsn = Module.concat([Elixir,mod,Mixfile]).project[:version] |> to_char_list
      {d,vsn}
    end
  end

  def generate_release do
    generate_rel_file_and_folders
    generate_config_file
    generate_tar_file
  end

  def generate_rel_file_and_folders do
    File.mkdir_p! "rel/bin"
    File.mkdir_p! "rel/config"
    write_term "rel/sequeler.rel", get_rel_term
  end

  def generate_tar_file do
    File.cd! "rel", fn() ->
      :systools.make_script('sequeler', [:local])
      :systools.make_tar('sequeler')
    end
  end

  def generate_config_file do
    conf = Mix.Config.read! "config/config.exs"
    write_term "rel/sys.config", conf
  end

  @doc """
    Writes an Elixir/Erlang term to the provided path
  """
  def write_term(path, term) do
    :file.write_file('#{path}', :io_lib.fwrite('~p.\n', [term]))
  end

  defp get_deps_term do
    get_libs
    |> Enum.map(fn({lib,vsn}) -> {lib,vsn,:load} end)
    |> Enum.concat(get_apps)
  end

  defp get_rel_term do
    {:release,
    {'sequeler',to_char_list(Sequeler.Mixfile.project[:version])},
    {:erts,'6.2'},
    get_deps_term}
  end

end
