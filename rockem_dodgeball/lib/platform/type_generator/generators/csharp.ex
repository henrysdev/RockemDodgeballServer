defmodule TypeGenerator.Generators.CSharp do
  def gen_csharp_types(primitives, types_map, outdir) do
    types_map
    |> Map.keys()
    |> Enum.map(&new_csharp_classtype(primitives, &1, Map.get(types_map, &1), outdir))
  end

  defp whitespace(indent) do
    " "
    |> List.duplicate(indent)
    |> Enum.join()
  end

  def new_classtype_field([field_type, field_name], indent) do
    whitespace(indent) <> "public #{field_type} #{field_name};"
  end

  def new_bytefield_write([field_type, field_name], primitives, indent) do
    whitespace(indent) <>
      if MapSet.member?(primitives, field_type) do
        "writer.Write(this.#{field_name});\n"
      else
        "this.#{field_name}.WriteStream(writer);"
      end
  end

  def new_bytefield_read([field_type, field_name], primitives, indent) do
    whitespace(indent) <>
      if MapSet.member?(primitives, field_type) do
        # TODO use map to lookup correct type conversion
        "result.#{field_name} = reader.ReadType();\n"
      else
        "this.#{field_name}.ReadStream(reader);"
      end

    whitespace(indent) <> "result.#{field_name} = reader.ReadSingle();\n"
  end

  def new_csharp_classtype(primitives, type_name, fields, outdir) do
    indent = 4
    # https://www.genericgamedev.com/general/converting-between-structs-and-byte-arrays/
    # classtype = """
    # using System.IO;
    # using UnityEngine;

    # public class #{type_name}
    # {
    # #{Enum.map(fields, &new_classtype_field(&1, indent))}

    #     public void WriteStream(BinaryWriter writer)
    #     {
    # #{Enum.map(fields, &new_bytefield_write(&1, primitives, indent * 2))}
    #     }

    #     public byte[] ToArray()
    #     {
    #         var stream = new MemoryStream();
    #         var writer = new BinaryWriter(stream);
    #         WriteStream(writer);
    #         return stream.ToArray();
    #     }

    #     public static #{type_name} FromArray(byte[] bytes)
    #     {
    #         var stream = new MemoryStream(bytes);
    #         var reader = new BinaryReader(stream);
    #         var result = default(#{type_name});
    # #{Enum.map(fields, &new_bytefield_read(&1, primitives, indent * 2))}
    #         return result;
    #     }
    # }
    # """
    classtype = """
    public class #{type_name}
    {
    #{fields |> Enum.map(&new_classtype_field(&1, indent)) |> Enum.join("\n")}
    }
    """

    {:ok, file} = File.open(Path.expand(outdir <> "/" <> type_name <> ".cs"), [:write])
    IO.binwrite(file, classtype)
    File.close(file)
  end
end
