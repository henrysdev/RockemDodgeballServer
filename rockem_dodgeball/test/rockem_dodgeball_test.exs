defmodule RockemDodgeballTest do
  use ExUnit.Case
  doctest RockemDodgeball

  test "starts AppSupervisor" do
    assert {:ok, _pid} = RockemDodgeball.main()
  end
end
