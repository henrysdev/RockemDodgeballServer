defmodule RockemDodgeball.GameServer.HelpersTest do
  use ExUnit.Case

  alias RockemDodgeball.GameServer.{
    Helpers
  }

  doctest Helpers

  test "add player if not seen before" do
    state = %{
      clients: %{
        "uid1" => {{127, 0, 0, 1}, 1234},
        "uid2" => {{127, 0, 0, 1}, 6789}
      }
    }

    client_update = %ClientGamestateUpdate{
      player: %{
        "playerId" => "uid3"
      }
    }

    conn = {{127, 0, 0, 1}, 1337}

    expected_state = %{
      clients: %{
        "uid1" => {{127, 0, 0, 1}, 1234},
        "uid2" => {{127, 0, 0, 1}, 6789},
        "uid3" => conn
      }
    }

    new_state = Helpers.add_if_new_client(state, client_update.player, conn)
    assert new_state === expected_state
  end

  test "dont add player if in map" do
    state = %{
      clients: %{
        "uid1" => {{127, 0, 0, 1}, 1234},
        "uid2" => {{127, 0, 0, 1}, 6789}
      }
    }

    client_update = %ClientGamestateUpdate{
      player: %{
        "playerId" => "uid2"
      }
    }

    conn = {{127, 0, 0, 1}, 6789}
    new_state = Helpers.add_if_new_client(state, client_update.player, conn)
    assert new_state === state
  end
end
