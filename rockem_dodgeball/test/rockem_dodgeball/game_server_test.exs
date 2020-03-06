defmodule RockemDodgeball.GameServerTest do
  use ExUnit.Case
  doctest RockemDodgeball.GameServer

  @server_port 27189
  @client_port 12345

  @tickrate 60
  @gs_id "asdf"

  test "starts GameServer with listening udp port" do
    {:ok, super_pid} =
      RockemDodgeball.GameServer.start_link([@gs_id, @server_port, @tickrate, []])

    assert :ok == GenServer.cast(super_pid, {:udp, {}, {{127, 0, 0, 1}, @client_port}, "abc123"})
  end

  test "broadcast a message to clients" do
    fake_client_update =
      %ClientGamestateUpdate{
        player: %PlayerData{
          playerId: "okok"
        }
      }
      |> Poison.encode!()

    {:ok, server_pid} =
      RockemDodgeball.GameServer.start_link([@gs_id, @server_port, @tickrate, []])

    Process.sleep(20)

    client_socket = Socket.UDP.open!(@client_port)

    Process.sleep(20)

    :gen_udp.send(client_socket, {127, 0, 0, 1}, @server_port, fake_client_update)

    received_gamestate =
      client_socket
      |> Socket.Datagram.recv!()

    assert received_gamestate != nil

    # :gen_udp.recv(client_socket, 0) |> Poison.decode!(as: %ServerGamestateUpdate{})

    # assert received_gamestate.tickTimestamp > 0
    # # Socket.Datagram.send!(my_client, "data", to)

    # # :gen_udp.send(my_client, {127, 0, 0, 1}, @server_port, "BROADCAST")

    # IO.puts "AAA"
    # client_socket |> Socket.Datagram.recv!() |> IO.inspect()
    # IO.puts "BBB"

    # # TODO find way to get back socket ref instead of pid to
    # # test with
    # # spawn fn -> :gen_udp.send(server_pid, {127, 0, 0, 1}, @server_port, "BROADCAST") end
    # client_socket |> Socket.Datagram.recv!() |> IO.inspect()
  end
end
