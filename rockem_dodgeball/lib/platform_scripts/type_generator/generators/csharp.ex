defmodule TypeGenerator.Generators.CSharp do
  def gen_csharp_types(types_map, outdir) do
    types_map
    |> Map.keys()
    |> Enum.map(&new_csharp_classtype(&1, Map.get(types_map, &1), outdir))
  end

  def new_classtype_field([field_type, field_name]) do
    "    public #{field_type} #{field_name};"
  end

  def new_csharp_classtype(type_name, fields, outdir) do
    classtype =
      "public class #{type_name}\n{\n" <>
        (fields
         |> Enum.map(&new_classtype_field(&1))
         |> Enum.join("\n")) <>
        "\n}\n"

    {:ok, file} = File.open(outdir <> "/" <> type_name <> ".cs", [:write])
    IO.binwrite(file, classtype)
    File.close(file)
  end
end
