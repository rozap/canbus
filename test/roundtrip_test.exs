defmodule RoundtripTest do
  use ExUnit.Case
  use ExUnitProperties
  alias Canbus.{Dbc, Encode, Decode}
  import TestHelpers

  property "can encode/decode things" do
    {:ok, dbc} = Dbc.parse(dbc("fome"))

    message_ids = Enum.map(Map.keys(dbc.message), &constant/1)

    generator = bind(one_of(message_ids), fn id ->
      m = Map.get(dbc.message, id)

      fixed_list(
        Enum.map(m.signals, fn s ->
          {min_val, max_val} = s.range
          {constant(s.name), integer(trunc(min_val)..trunc(max_val))}
        end)
      )

    end)


    check all frame <- generator do
      m = Enum.into(frame, %{})
      [{:ok, encoded}] = Encode.encode(dbc, m)
      {:ok, decoded} = Decode.decode(dbc, encoded)

      Enum.each(frame, fn {key, og_value} ->
        decoded_value = Map.get(decoded, key)
        assert_in_delta(og_value, decoded_value, 0.0001)
      end)
    end
  end
end
