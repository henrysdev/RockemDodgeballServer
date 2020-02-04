defmodule TypeGenerator do
  def read_in_types_file(types_file, csharp_outdir, elixir_outdir) do
    TypeGenerator.Generators.read_in_types_file(types_file, csharp_outdir, elixir_outdir)
  end
end

TypeGenerator.read_in_types_file(
  "config/types.rpc",
  "generated/types/csharp",
  "generated/types/elixir"
)
