defmodule TypeGenerator do
  def read_in_types_file(types_file, csharp_outdir, elixir_outdir) do
    TypeGenerator.Generators.read_in_types_file(types_file, csharp_outdir, elixir_outdir)
  end
end

TypeGenerator.read_in_types_file(
  "config/types.rpc",
  "~/RockemDodgeball/RockemDodgeball/Assets/Scripts/Networking/Transport/Types/Generated",
  "lib/platform/types"
)
