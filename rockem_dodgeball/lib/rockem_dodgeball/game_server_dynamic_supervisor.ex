defmodule RockemDodgeball.GameServerDynamicSupervisor do
  use DynamicSupervisor

  alias RockemDodgeball.{
    GameServer
  }

  @port 27189
  @tickrate 15

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  add_game_server creates a new game server process
  with the given gs_id (game server id)
  """
  def add_game_server(gs_id) do
    DynamicSupervisor.start_child(__MODULE__, {GameServer, [@port, @tickrate, gs_id]})
  end

  def active_game_servers() do
    DynamicSupervisor.which_children(__MODULE__)
  end
end
