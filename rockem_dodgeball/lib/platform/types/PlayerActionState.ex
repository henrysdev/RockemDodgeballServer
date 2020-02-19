defmodule PlayerActionState do
  defstruct(
    # bool
    isMoving: nil,
    # bool
    isGrounded: nil,
    # bool
    isWindingUp: nil,
    # bool
    isHit: nil
  )
end
