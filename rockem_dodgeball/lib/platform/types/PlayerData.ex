defmodule PlayerData do
  defstruct(
    # long
    playerId: nil,
    # string
    name: nil,
    # int
    score: nil,
    # string
    teamName: nil,
    # Vector3Data
    position: nil,
    # QuaternionData
    rotation: nil,
    # Vector3Data
    velocity: nil,
    # PlayerActionState
    actionState: nil,
    # PlayerHealthState
    healthState: nil
  )
end
