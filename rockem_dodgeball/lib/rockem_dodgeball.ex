defmodule RockemDodgeball do
  alias RockemDodgeball.{
    GameServerDynamicSupervisor
  }

  def main do
    AppSupervisor.start_link()

    {:ok, game_server} = GameServerDynamicSupervisor.add_game_server("my_server")
  end
end
