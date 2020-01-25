defmodule RockemDodgeball.GameServer do
  use GenServer

  alias Utils.{
    Transport
  }

  alias RockemDodgeball.GameServer.{
    Ticker,
    Gamestate
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
  # TODO route behavior based on data traits
  def handle_info({:udp, socket, ip, port, data} = info, state) do
    IO.inspect(data |> Poison.decode!())
    message = Poison.decode!(data)

    %{
      "player" => %{
        "playerId" => player_id
      }
    } = message

    %{
      players: players,
      socket: new_socket,
      gamestate_pid: gamestate_pid
    } = state

    players =
      case Map.has_key?(players, player_id) do
        false -> Map.put(players, player_id, {ip, port})
        _true -> players
      end

    state = Map.put(state, :players, players)

    Gamestate.update_gamestate(gamestate_pid, message)

    IO.inspect(state)

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
    IO.inspect({:CLIENT, clients})

    gamestate_data = Gamestate.fetch_gamestate(gamestate_pid)

    gamestate_data =
      gamestate_data
      |> Map.put("tickTimestamp", tick)
      |> Poison.encode!()

    clients |> Enum.each(&Transport.send_data(socket, gamestate_data, &1))
    {:noreply, state}
  end
end
