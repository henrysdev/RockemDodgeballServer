defmodule TypeGenerator.Generators do
  alias TypeGenerator.{
    Generators
  }

  @primitive_types MapSet.new([
                     "short",
                     "int",
                     "long",
                     "bool",
                     "float",
                     "double",
                     "string"
                   ])

  def primitive_type?(field_type) do
    MapSet.member?(@primitive_types, field_type)
  end

  def custom_type?(field_type, custom_types) do
    Map.has_key?(custom_types, field_type)
  end

  def bad_typecheck([field_type, field_name]) do
    IO.puts("Type check failed for field #{field_name} of type #{field_type}")
    System.stop(1)
  end

  def check_type([field_type, _field_name] = field, custom_types) do
    case {primitive_type?(field_type), custom_type?(field_type, custom_types)} do
      {false, false} -> bad_typecheck(field)
      {true, _} -> true
      {_, true} -> true
    end
  end

  def type_checked?(fields, custom_types) do
    checked_results = Enum.filter(fields, &check_type(&1, custom_types))
    length(fields) == length(checked_results)
  end

  def parse_fields(raw_fields) do
    raw_fields
    |> String.replace(~r/;|\n/, "")
    |> String.split("    ")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&String.split(&1, " "))
  end

  def parse_struct(struct_text, {custom_types, all_field_types}) do
    struct_text = String.trim(struct_text, " ")

    regex = ~r/(?<type_name>[A-Za-z\d]+) {(?<fields>[\sA-Za-z;\d\[\]]+)}[\s]+/
    captures = Regex.named_captures(regex, struct_text)

    %{
      "type_name" => type_name,
      "fields" => raw_fields
    } = captures

    # Parse fields
    fields = parse_fields(raw_fields)

    # Add field type to types we've seen (for typechecking later)
    all_field_types =
      fields
      |> Enum.reduce(all_field_types, &MapSet.put(&2, &1))

    # Update custom types with new type definition
    custom_types = custom_types |> Map.put_new(type_name, fields)

    {custom_types, all_field_types}
  end

  def read_in_types_file(filepath, csharp_outdir, elixir_outdir) do
    {:ok, contents} = File.read(filepath)

    {custom_types, all_field_types} =
      contents
      |> String.split("struct ", trim: true)
      |> Enum.reduce({%{}, MapSet.new()}, &parse_struct(&1, &2))

    # Type check each unique field type encountered
    all_field_types
    |> Enum.map(fn [field_type, field_name] ->
      # Handle array data type
      field_type =
        if String.ends_with?(field_type, "[]") do
          String.slice(field_type, 0..(String.length(field_type) - 3))
        else
          field_type
        end

      [field_type, field_name]
    end)
    |> Enum.each(&check_type(&1, custom_types))

    # If program has not exited early during type check, generate files
    generate_type_files(custom_types, csharp_outdir, elixir_outdir)
  end

  def generate_type_files(custom_types, csharp_outdir, elixir_outdir) do
    Generators.CSharp.gen_csharp_types(custom_types, csharp_outdir)
    Generators.Elixir.gen_elixir_types(custom_types, elixir_outdir)
  end
end
