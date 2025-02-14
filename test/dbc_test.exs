defmodule DbcTest do
  use ExUnit.Case
  import TestHelpers
  alias Canbus.Dbc, as: D

  test "can lex" do
    assert {:ok, _} = dbc("fome") |> D.lex() |> IO.inspect
  end

  test "can parse" do
    {:ok, tokens} = dbc("fome") |> D.parse() |> IO.inspect()
  end
end
