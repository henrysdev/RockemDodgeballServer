defmodule AppSupervisor do
  use Supervisor

  alias RockemDodgeball.{
    GameServerDynamicSupervisor
  }

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: :app_supervisor)
  end

  def init([]) do
    children = [
      {GameServerDynamicSupervisor, name: :match_supervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
