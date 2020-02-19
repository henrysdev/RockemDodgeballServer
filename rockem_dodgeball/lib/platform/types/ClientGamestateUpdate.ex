defmodule ClientGamestateUpdate do
  defstruct(
    # ClientMetadata
    metadata: nil,
    # PlayerData
    player: nil,
    # BallData[]
    balls: []
  )
end
