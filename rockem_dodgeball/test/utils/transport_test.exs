defmodule Utils.TransportTest do
  use ExUnit.Case
  doctest Utils.Transport

  test "reverses binary" do
    bin = <<1, 2, 3, 4>>
    assert <<4, 3, 2, 1>> = bin |> Utils.Transport.reverse_binary()
  end

  test "reads in vector3" do
    bin = <<0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64>>
    assert {1.0, 2.0, 3.0} == bin |> Utils.Transport.read_vector3()
  end
end
