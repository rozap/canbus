defmodule EncodeTest do
  alias Canbus.{Dbc, Encode, Decode}
  import TestHelpers

  use ExUnit.Case

  test "can encode a frame" do
    {:ok, dbc} = Dbc.parse(dbc("fome-516"))

    [{:ok, frame}] =
      Encode.encode(dbc, %{
        "OilPress" => 50,
        "OilTemperature" => 20,
        "FuelTemperature" => 50,
        "BattVolt" => 14
      })

    %{
      "BattVolt" => 14.0,
      "FuelTemperature" => 50,
      "OilPress" => prs,
      "OilTemperature" => 20
    } = Decode.decode!(dbc, frame)

    assert_in_delta(prs, 50, 0.001)
  end
end
