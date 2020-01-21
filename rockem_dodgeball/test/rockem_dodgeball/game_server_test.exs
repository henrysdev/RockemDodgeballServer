defmodule RockemDodgeball.GameServerTest do
  use ExUnit.Case
  doctest RockemDodgeball.GameServer

  @server_port 27189
  @client_port 12345

  test "starts GameServer with listening udp port" do
    {:ok, super_pid} = RockemDodgeball.GameServer.start_link(@server_port)
    assert :ok == GenServer.cast(super_pid, {:udp, {}, {{127, 0, 0, 1}, @client_port}, "abc123"})
  end

  # TODO make readme w/ http://asciiflow.com/
  # test "broadcast message to clients" do
  #   {:ok, server_pid} = RockemDodgeball.GameServer.start_link(@server_port)
  #   my_client = Socket.UDP.open!(@client_port)
  #   # server = Socket.UDP.open!(@server_port)
  #   other_clients = [
  #     Socket.UDP.open!(12346),
  #     Socket.UDP.open!(12347),
  #     Socket.UDP.open!(12348),
  #     Socket.UDP.open!(12349),
  #   ]

  #   # TODO find way to get back socket ref instead of pid to
  #   # test with
  #   spawn fn -> :gen_udp.send(server_pid, {127, 0, 0, 1}, @server_port, "BROADCAST") end
  #   my_client |> Socket.Datagram.recv! |> IO.inspect
  # end
end
