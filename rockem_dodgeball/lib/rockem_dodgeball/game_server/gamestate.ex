defmodule RockemDodgeball.GameServer.Gamestate do
  use GenServer

  def start_link(gs_id) do
    GenServer.start_link(__MODULE__, [gs_id], name: __MODULE__)
  end

  def init([gs_id]) do
    {:ok, %{}}
  end

  def update_gamestate(pid, new_state) do
    GenServer.cast(pid, {:update_gamestate, new_state})
  end

  def fetch_gamestate(pid) do
    GenServer.call(pid, {:fetch_gamestate})
  end

  def handle_cast({:update_gamestate, new_state}, state) do
    # TODO break this logic out into a transform
    state = new_state

    state = %{
      "enemy" => new_state["player"],
      "balls" => new_state["balls"]
    }

    {:noreply, state}
  end

  def handle_call({:fetch_gamestate}, _from, state) do
    {:reply, state, state}
  end
end
