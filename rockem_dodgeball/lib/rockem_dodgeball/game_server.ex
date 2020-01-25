defmodule RockemDodgeball.GameServer do
  use GenServer

  alias Utils.{
    Transport
  }

  alias RockemDodgeball.GameServer.{
    Ticker,
    Gamestate,
    Helpers
  }

  @moduledoc """
  The GameServer module provides functions for interacting
  with the UDP network layer of the virtual game server process
  """

  def start_link([port, tickrate, gs_id]) do
    GenServer.start_link(__MODULE__, [port, tickrate, gs_id])
  end

  def init([port, tickrate, gs_id]) do
    {:ok, socket} = :gen_udp.open(port, [:binary, active: true])
    {:ok, ticker_pid} = Ticker.start_link([tickrate, self()])
    {:ok, gamestate_pid} = Gamestate.start_link(gs_id)

    state = %{
      players: %{},
      socket: socket,
      ticker_pid: ticker_pid,
      gamestate_pid: gamestate_pid,
      gs_id: gs_id
    }

    {:ok, state}
  end

  def broadcast_gamestate(pid, tick) do
    GenServer.cast(pid, {:broadcast_gamestate, tick})
  end

  @doc """
    This is the main callback function for all UDP traffic.
    Incoming requests are handled as follows:
    # 1. Deserialize request
    # 2. Check for new player
    # 3. Route to correct place
    # 4. Update gamestate
  """
  def handle_info({:udp, _socket, ip, port, data}, state) do
    %{
      gamestate_pid: gamestate_pid
    } = state

    payload = Poison.decode!(data)

    state =
      state
      |> Helpers.add_if_new_player(payload, {ip, port})

    Gamestate.update_gamestate(gamestate_pid, payload)
    {:noreply, state}
  end

  def handle_cast({:broadcast_gamestate, tick}, state) do
    IO.puts("broadcasting message for tick - #{DateTime.utc_now()}")

    %{
      players: players,
      socket: socket,
      gamestate_pid: gamestate_pid
    } = state

    clients = players |> Map.values()

    gamestate_data = Gamestate.fetch_gamestate(gamestate_pid)

    gamestate_data =
      gamestate_data
      |> Map.put("tickTimestamp", tick)
      |> Poison.encode!()

    clients |> Enum.each(&Transport.send_data(socket, gamestate_data, &1))
    {:noreply, state}
  end
end
