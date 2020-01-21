defmodule RockemDodgeball.GameServer.GameServerDynamicSupervisor do
  use DynamicSupervisor

  alias RockemDodgeball.{
    GameServer
  }

  @port 27189

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_game_server() do
    DynamicSupervisor.start_child(__MODULE__, {GameServer, @port})
  end

  def active_game_servers() do
    DynamicSupervisor.which_children(__MODULE__)
  end
end
