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

  test "splits binary at given index" do
    bin = <<1, 2, 3, 4>>
    assert {<<1, 2>>, <<3, 4>>} == bin |> Utils.Transport.split_binary_at_index(2)
  end

  test "reads in quaternion" do
    bin = <<0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64, 0, 0, 128, 64>>
    assert {1.0, 2.0, 3.0, 4.0} == bin |> Utils.Transport.read_quaternion()
  end

  test "reads simple transform" do
    bin =
      <<0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64, 0, 0, 128, 63, 0, 0, 0, 64, 0, 0, 64, 64, 0, 0,
        128, 64>>

    assert {{1.0, 2.0, 3.0}, {1.0, 2.0, 3.0, 4.0}} ==
             bin |> Utils.Transport.read_simple_transform()
  end
end
