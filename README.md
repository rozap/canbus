# Canbus
parse dbc files and use them to interpret can frames

# Status
probably doesn't work for you. it only works enough for me.

# Usage
```elixir
{:ok, dbc} = Canbus.Dbc.parse("something.dbc")
# Might be something like
#%Canbus.Dbc{
#  message: %{
#    512 => %{
#      id: 512,
#      name: "BASE0",
#      size: 8,
#      sender: "Vector__XXX",
#      signals: [
#        %{
#          name: "WarningCounter",
#          size: 16,
#          unit: "",
#          range: {0, 0},
#          endianness: :little,
#          sign: :unsigned, 
#          multiplexer: nil,
#          start_bit: 0,
#          scale: {1, 0},
#          receivers: ["Vector__XXX"]
#        }
#        ...etc
#


# decode a stream of frames given the dbc 
Enum.map(some_frames(), fn {_can_id, _dlc, _bytes} = frame -> 
  Canbus.Decode.decode(dbc, frame)
end)
# might be something like
#  %{
#    "AUX1Temp" => 0,
#    "AUX2Temp" => 0,
#    "CoolantTemp" => 29,
#    "FuelLevel" => 0.0,
#    "IntakeTemp" => 25,
#    "MAP" => 94.49999055,
#    "MCUTemp" => 23
#  }
#  %{
#    "BattVolt" => 0.007,
#    "FuelTemperature" => 0,
#    "OilPress" => 0.0,
#    "OilTemperature" => 0
#  }
```