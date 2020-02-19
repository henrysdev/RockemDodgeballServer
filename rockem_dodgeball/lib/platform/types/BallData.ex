defmodule BallData do
  defstruct(
    # short
    ballId: nil,
    # Vector3Data
    position: nil,
    # QuaternionData
    rotation: nil,
    # Vector3Data
    velocity: nil,
    # int
    damage: nil,
    # bool
    isLive: nil,
    # long
    throwerPlayerId: nil
  )
end
