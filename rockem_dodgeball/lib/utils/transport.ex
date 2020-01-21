defmodule Utils.Transport do
  @doc """
  Sends `data` to the `to` value, where `to` is a tuple of
  { host, port } like {{127, 0, 0, 1}, 27189}
  """
  def send_data(server, data, {host, port} = to) do
    Socket.Datagram.send!(server, data, to)
  end
end
