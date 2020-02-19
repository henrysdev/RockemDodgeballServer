defmodule ClientMetadata do
  defstruct(
    # long
    clientId: nil,
    # short
    version: nil,
    # long
    gameServerId: nil,
    # long
    matchId: nil,
    # long
    timestamp: nil
  )
end
