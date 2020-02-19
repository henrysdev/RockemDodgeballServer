defmodule ServerGamestateUpdate do
  defstruct(
    # long
    tickTimestamp: nil,
    # GameInfo
    gameInfo: nil,
    # PlayerData[]
    players: nil,
    # BallData[]
    balls: nil
  )
end
