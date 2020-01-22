defmodule Utils.Transport do
  @doc """
  Sends `data` to the `to` value, where `to` is a tuple of
  { host, port } like {{127, 0, 0, 1}, 27189}
  """
  def send_data(server, data, {_host, _port} = to) do
    Socket.Datagram.send!(server, data, to)
  end

  def take_from_binary(binary, n) do
    <<chunk::size(n), rest::bitstring>> = binary
    {chunk, rest}
  end

  def reverse_binary(binary) do
    binary
    |> :binary.bin_to_list()
    |> Enum.reverse()
    |> :binary.list_to_bin()
  end

  def read_vector3(binary) do
    <<x::binary-size(4), y::binary-size(4), z::binary-size(4)>> = binary

    [x, y, z]
    |> Enum.map(&reverse_binary(&1))
    |> Enum.map(&XDR.Type.Float.decode!(&1))
    |> Enum.map(fn {val, _} -> val end)
    |> List.to_tuple()
  end
end
