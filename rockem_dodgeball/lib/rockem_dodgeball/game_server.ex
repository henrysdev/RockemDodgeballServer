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
    GenServer.start_link(__MODULE__, {port, %{"players" => []}})
  end

  def init({port, state}) do
    {:ok, socket} = :gen_udp.open(port, [:binary, active: true])
    {:ok, state}
  end

  def handle_info({:udp, socket, ip, port, data}, state) do
    IO.inspect(data |> Transport.read_vector3())

    case data do
      "BROADCAST" -> broadcast_to_clients(socket, Map.get(state, "players"), "psa!")
      _ -> Transport.send_data(socket, data, {ip, port})
    end

    :gen_udp.send(socket, data)
    {:noreply, state}
  end

  defp broadcast_to_clients(server, clients, data) do
    clients |> Enum.each(&Transport.send_data(server, data, &1))
  end
end
