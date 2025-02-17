defmodule DecodeTest do
  alias Canbus.{Dbc, Decode}
  import TestHelpers

  use ExUnit.Case

  setup do
    {:ok, dbc} = Dbc.parse(dbc("fome"))
    {:ok, %{dbc: dbc}}
  end

  test "can decode a frame", %{dbc: dbc} do
    frames =
      txt_frames("can-log")
      |> Stream.map(fn frame ->
        Decode.decode(dbc, frame)
      end)
      |> Enum.into([])

    oils = Enum.filter(frames, fn f ->
      Map.has_key?(f, "OilPress") && f["OilPress"] > 100
    end)

    volts = Enum.filter(frames, fn f ->
      Map.has_key?(f, "BattVolt") && f["BattVolt"] > 12
    end)

    assert length(oils) == 5
    assert length(volts) == 10
  end
end
