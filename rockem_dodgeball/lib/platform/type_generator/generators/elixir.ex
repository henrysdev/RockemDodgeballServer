defmodule TypeGenerator.Generators.Elixir do
  def gen_elixir_types(types_map, outdir) do
    types_map
    |> Map.keys()
    |> Enum.map(&new_elixir_struct(&1, Map.get(types_map, &1), outdir))
  end

  def new_struct_field([field_type, field_name]) do
    "    #{field_name}: nil, # #{field_type}"
  end

  def new_elixir_struct(type_name, fields, outdir) do
    classtype =
      "defmodule #{type_name} do\n\n" <>
        "  defstruct(\n" <>
        (fields
         |> Enum.map(&new_struct_field(&1))
         |> Enum.join("\n")) <>
        "\n  )\n\nend\n"

    {:ok, file} = File.open(outdir <> "/" <> type_name <> ".ex", [:write])
    IO.binwrite(file, classtype)
    File.close(file)
  end
end
