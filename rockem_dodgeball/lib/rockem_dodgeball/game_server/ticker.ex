defmodule RockemDodgeball.GameServer.Ticker do
  use GenServer

  @tickrate 1000

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def reset_timer() do
    GenServer.call(__MODULE__, :reset_timer)
  end

  def init(state) do
    timer = Process.send_after(self(), :tick, @tickrate)
    {:ok, %{timer: timer}}
  end

  def handle_call(:reset_timer, _from, %{timer: timer}) do
    :timer.cancel(timer)
    timer = Process.send_after(self(), :tick, @tickrate)
    {:reply, :ok, %{timer: timer}}
  end

  def handle_info(:tick, state) do
    # Do the tick you desire here
    IO.puts("broadcasting message for tick - #{DateTime.utc_now()}")
    # TODO send broadcast message from gameserver

    # Start the timer again
    timer = Process.send_after(self(), :tick, @tickrate)

    {:noreply, %{timer: timer}}
  end

  # So that unhanded messages don't error
  def handle_info(_, state) do
    {:ok, state}
  end
end
