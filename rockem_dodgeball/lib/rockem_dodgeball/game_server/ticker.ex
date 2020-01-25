defmodule RockemDodgeball.GameServer.Ticker do
  use GenServer

  alias RockemDodgeball.{
    GameServer
  }

  def start_link([tickrate, game_server]) do
    GenServer.start_link(__MODULE__, [tickrate, game_server], name: __MODULE__)
  end

  def init([tickrate, game_server]) do
    timer = Process.send_after(self(), :tick, tickrate)

    state = %{
      timer: timer,
      tickrate: tickrate,
      game_server: game_server
    }

    {:ok, state}
  end

  def reset_timer() do
    GenServer.call(__MODULE__, :reset_timer)
  end

  def handle_call(:reset_timer, _from, state) do
    %{
      timer: timer,
      tickrate: tickrate,
      game_server: game_server
    } = state

    :timer.cancel(timer)
    timer = Process.send_after(self(), :tick, tickrate)

    state = %{
      timer: timer,
      tickrate: tickrate,
      game_server: game_server
    }

    {:reply, :ok, state}
  end

  def handle_info(:tick, state) do
    %{
      timer: timer,
      tickrate: tickrate,
      game_server: game_server
    } = state

    timestamp = System.system_time(:millisecond)
    GameServer.broadcast_gamestate(game_server, timestamp)

    # Start the timer again
    timer = Process.send_after(self(), :tick, tickrate)

    state = %{
      timer: timer,
      tickrate: tickrate,
      game_server: game_server
    }

    {:noreply, state}
  end

  # So that unhanded messages don't error
  def handle_info(_, state) do
    {:ok, state}
  end
end
