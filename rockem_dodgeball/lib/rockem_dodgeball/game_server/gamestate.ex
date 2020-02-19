defmodule RockemDodgeball.GameServer.Gamestate do
  use GenServer

  alias RockemDodgeball.GameServer.{
    Helpers
  }

  defstruct(
    # Map from playerId -> PlayerData
    players: %{},

    # Map from teamId -> TeamData
    teams: %{},

    # Map from ballId -> BallData
    balls: %{}
  )

  def start_link(gs_id) do
    GenServer.start_link(__MODULE__, [gs_id], name: __MODULE__)
  end

  def init([gs_id]) do
    {:ok, %__MODULE__{}}
  end

  def update_gamestate(pid, new_state) do
    GenServer.cast(pid, {:update_gamestate, new_state})
  end

  def fetch_gamestate(pid) do
    GenServer.call(pid, {:fetch_gamestate})
  end

  def handle_cast(
        {:update_gamestate, client_update = %ClientGamestateUpdate{}},
        gamestate = %__MODULE__{}
      ) do
    client_player = struct(PlayerData, client_update.player)

    {updated_player, changed?} =
      case Map.get(gamestate.players, client_player.playerId) do
        nil -> {client_player, true}
        server_player -> Helpers.shallow_upsert_player_data(server_player, client_player)
      end

    gamestate =
      if changed? do
        struct(__MODULE__, Map.put(gamestate.players, client_player.playerId, updated_player))
      else
        gamestate
      end

    {:noreply, gamestate}
  end

  def handle_call({:fetch_gamestate}, _from, state) do
    {:reply, state, state}
  end
end
