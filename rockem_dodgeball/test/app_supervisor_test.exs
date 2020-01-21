defmodule AppSupervisorTest do
  use ExUnit.Case
  doctest AppSupervisor

  test "starts AppSupervisor with correct supervisor tree" do
    {:ok, super_pid} = AppSupervisor.start_link()
    assert Supervisor.which_children(super_pid) |> length == 1

    assert [{RockemDodgeball.GameServer.GameServerDynamicSupervisor, _, _, _}] =
             Supervisor.which_children(super_pid)
  end
end
