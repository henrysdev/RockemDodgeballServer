defmodule RockemDodgeball.GameServer.Helpers do
  def add_if_new_player(%{players: players} = state, %{"player" => player}, conn) do
    player_id = Map.get(player, "playerId")

    players =
      case Map.has_key?(players, player_id) do
        false -> Map.put(players, player_id, conn)
        _true -> nil
      end

    case players do
      nil -> state
      _updated_players -> Map.put(state, :players, players)
    end
  end
end
