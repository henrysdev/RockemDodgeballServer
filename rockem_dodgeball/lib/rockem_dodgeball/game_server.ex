defmodule RockemDodgeball.GameServer do
  use GenServer

  alias Utils.{
    Transport
  }

  @moduledoc """
  The GameServer module provides functions for interacting
  with the UDP network layer of the virtual game server process
  """

  def start_link(port) do
    GenServer.start_link(__MODULE__, port)
  end

  def init(port) do
    {:ok, socket} = :gen_udp.open(port, [:binary, active: true])

    state = %{
      players: [],
      socket: socket
    }

    {:ok, state}
  end

  def handle_info({:udp, socket, ip, port, data} = info, state) do
    # TODO
    # 1. Decode message
    # 2. Update current gamestate

    :gen_udp.send(socket, data)
    {:noreply, state}
  end

  defp broadcast_gamestate(server, clients, data) do
    # TODO
    # 1. Pull gamestate
    # 2. Broadcast gamestate to all clients

    clients |> Enum.each(&Transport.send_data(server, data, &1))
  end
end
