require Logger, as: L
require Bottler.Helpers, as: H

defmodule Bottler.Install do
  alias Bottler.SSH

  @moduledoc """
    Functions to deploy an already shipped release on remote servers.
  """

  @doc """
    Install previously shipped release on remote servers, making it _current_
    release. Actually running release is not touched. Next restart will run
    the new release.
  """
  def install(servers) do
    :ssh.start

    results = servers |> Keyword.values |> H.in_tasks( fn(args) -> on_server(args) end )

    all_ok = Enum.all?(results, &(&1 == :ok))
    if all_ok, do: :ok, else: {:error, results}
  end

  defp on_server(args) do
    ip = args[:public_ip] |> to_char_list

    {:ok, conn} = :ssh.connect(ip, 22,
                        [{:user,'epdp'},{:silently_accept_hosts,true}], 5000)

    vsn = Sequeler.version
    L.info "Installing #{vsn}..."

    place_files conn, vsn
    make_current conn, vsn
    cleanup_old_releases conn
    :ok
  end

  # Decompress release file, put it in place, and make needed movements
  #
  defp place_files(conn, vsn) do
    L.info "Settling files..."
    SSH.cmd! conn, 'mkdir -p /home/epdp/sequeler/releases/#{vsn}'
    SSH.cmd! conn, 'mkdir -p /home/epdp/sequeler/pipes'
    SSH.cmd! conn, 'mkdir -p /home/epdp/sequeler/log'
    SSH.cmd! conn, 'mkdir -p /home/epdp/sequeler/tmp'
    {:ok, _, 0} = SSH.run conn,
          'tar --directory /home/epdp/sequeler/releases/#{vsn}/ -xf /tmp/sequeler.tar.gz'
    SSH.cmd! conn, 'ln -sf /home/epdp/sequeler/tmp /home/epdp/sequeler/releases/#{vsn}/tmp'
    SSH.cmd! conn,
          'ln -sf /home/epdp/sequeler/current/releases/#{vsn} /home/epdp/sequeler/current/boot'
  end

  defp make_current(conn, vsn) do
    L.info "Marking release as current..."
    {:ok, _, 0} = SSH.run conn,
          'ln -sfn /home/epdp/sequeler/releases/#{vsn}  /home/epdp/sequeler/current'
  end

  defp cleanup_old_releases(conn) do
    L.info "Cleaning up old releases..."
    {:ok, res, 0} = SSH.run conn, 'ls -t /home/epdp/sequeler/releases'
    excess_releases = res |> String.split("\n") |> Enum.slice(5..-2)

    for r <- excess_releases do
      L.info "Cleaning up old #{r}..."
      {:ok, _, 0} = SSH.run conn, 'rm -fr /home/epdp/sequeler/releases/#{r}'
    end
  end

end
