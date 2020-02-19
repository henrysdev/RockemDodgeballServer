defmodule RockemDodgeball.GameServer.Helpers do
  def add_if_new_client(%{clients: clients} = state, client, conn) do
    client_id = Map.get(client, "playerId")

    clients =
      case Map.has_key?(clients, client_id) do
        false -> Map.put(clients, client_id, conn)
        _true -> nil
      end

    case clients do
      nil -> state
      _updated_clients -> Map.put(state, :clients, clients)
    end
  end

  @doc """
  Only upsert player data fields that have changed. Keep track on if
  there have been any changed fields and return this as not to do
  unnecessary writes
  """
  def shallow_upsert_player_data(server_player = %PlayerData{}, client_player = %PlayerData{}) do
    {updated_server_player, changed?} =
      server_player
      |> Map.keys()
      |> Enum.reduce({%PlayerData{}, false}, fn key, {acc, changed?} ->
        {val, diff?} =
          case Map.get(client_player, key) do
            nil -> {Map.get(server_player, key), changed?}
            new_val -> {new_val, true}
          end

        {Map.put(acc, key, val), diff?}
      end)
  end
end
