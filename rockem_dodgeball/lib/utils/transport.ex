defmodule Utils.Transport do
  @doc """
  Sends `data` to the `to` value, where `to` is a tuple of
  { host, port } like {{127, 0, 0, 1}, 27189}
  """

  def serialize(body) do
    Poison.encode!(body)
  end

  def deserialize(body, target_struct) do
    Poison.decode!(body, as: target_struct)
  end

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

  def split_binary_at_index(binary, n) do
    <<part::binary-size(n), rest::binary>> = binary
    {part, rest}
  end

  def read_vector3(binary) do
    <<x::binary-size(4), y::binary-size(4), z::binary-size(4)>> = binary

    [x, y, z]
    |> Enum.map(&reverse_binary(&1))
    |> Enum.map(&XDR.Type.Float.decode!(&1))
    |> Enum.map(fn {val, _} -> val end)
    |> List.to_tuple()
  end

  def read_quaternion(binary) do
    <<w::binary-size(4), x::binary-size(4), y::binary-size(4), z::binary-size(4)>> = binary

    [w, x, y, z]
    |> Enum.map(&reverse_binary(&1))
    |> Enum.map(&XDR.Type.Float.decode!(&1))
    |> Enum.map(fn {val, _} -> val end)
    |> List.to_tuple()
  end

  def read_simple_transform(binary) do
    {raw_vector3, raw_quaternion} = split_binary_at_index(binary, 12)
    vector3 = read_vector3(raw_vector3)
    quaternion = read_quaternion(raw_quaternion)
    {vector3, quaternion}
  end
end
