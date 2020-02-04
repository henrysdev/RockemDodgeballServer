defmodule TypeGenerator.GeneratorsTest do
  use ExUnit.Case
  doctest TypeGenerator.Generators

  @types_file "test/fake_types.rpc"
  @csharp_outdir "test/tmp_csharp_outdir/"
  @elixir_outdir "test/tmp_elixir_outdir/"

  setup_all do
    # Cleanup any stale files/directories before test
    case File.exists?(@types_file) do
      true -> File.rm!(@types_file)
      _false -> :ok
    end

    case File.exists?(@csharp_outdir) do
      true -> File.rm_rf!(@csharp_outdir)
      _false -> :ok
    end

    case File.exists?(@elixir_outdir) do
      true -> File.rm_rf!(@elixir_outdir)
      _false -> :ok
    end
  end

  setup do
    # Create test directories before each
    File.mkdir!(@csharp_outdir)
    File.mkdir!(@elixir_outdir)

    # Cleanup generated files and directories after each
    on_exit(fn ->
      File.rm_rf!(@csharp_outdir)
      File.rm_rf!(@elixir_outdir)

      case File.exists?(@types_file) do
        true -> File.rm!(@types_file)
        _false -> :ok
      end
    end)
  end

  test "properly generates csharp and elixir types" do
    # create fake file
    valid_types_text = """
    struct Foo {
        short field1;
        Bar field2;
        Zoo[] field3;
        string[] field4;
    }
    struct Bar {
        long field1;
    }
    struct Zoo {
        int anotherField;
    }
    """

    expected_foo_cs = """
    public class Foo
    {
        public short field1;
        public Bar field2;
        public Zoo[] field3;
        public string[] field4;
    }
    """

    expected_bar_cs = """
    public class Bar
    {
        public long field1;
    }
    """

    expected_zoo_cs = """
    public class Zoo
    {
        public int anotherField;
    }
    """

    expected_foo_ex = """
    defmodule Foo do

      defstruct(
        field1: nil, # short
        field2: nil, # Bar
        field3: nil, # Zoo[]
        field4: nil, # string[]
      )

    end
    """

    expected_bar_ex = """
    defmodule Bar do

      defstruct(
        field1: nil, # long
      )

    end
    """

    expected_zoo_ex = """
    defmodule Zoo do

      defstruct(
        anotherField: nil, # int
      )

    end
    """

    {:ok, file} = File.open(@types_file, [:write])
    IO.binwrite(file, valid_types_text)
    File.close(file)

    TypeGenerator.Generators.read_in_types_file(
      @types_file,
      @csharp_outdir,
      @elixir_outdir
    )

    assert expected_foo_cs == File.read!(@csharp_outdir <> "Foo.cs")
    assert expected_bar_cs == File.read!(@csharp_outdir <> "Bar.cs")
    assert expected_zoo_cs == File.read!(@csharp_outdir <> "Zoo.cs")

    assert expected_foo_ex == File.read!(@elixir_outdir <> "Foo.ex")
    assert expected_bar_ex == File.read!(@elixir_outdir <> "Bar.ex")
    assert expected_zoo_ex == File.read!(@elixir_outdir <> "Zoo.ex")
  end
end
