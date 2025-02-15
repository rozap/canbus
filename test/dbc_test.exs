defmodule DbcTest do
  use ExUnit.Case
  import TestHelpers
  alias Canbus.Dbc, as: D

  test "can lex" do
    assert {:ok, _} = dbc("fome") |> D.lex()
  end

  test "can parse a simple thing" do
    {:ok, p} =
      D.parse("""
      VERSION "x"

      NS_ :
        NS_DESC_
        CM_
        BA_DEF_
        BA_

      BS_:

      BU_:

      BO_ 3221225472 VECTOR__INDEPENDENT_SIG_MSG: 0 Vector__XXX
        SG_ AFR : 7|16@0+ (0.001,9) [0|0] "AFR" Vector__XXX

      BO_ 512 BASE0: 8 Vector__XXX
        SG_ WarningCounter : 0|16@1+ (1,0) [0|0] "" Vector__XXX
        SG_ LastError : 16|16@1+ (1,0) [0|0] "" Vector__XXX

      CM_ SG_ 3221225472 AFR "Current AFR Reading
      ";
      CM_ SG_ 3221225472 VVTPos "Current VVT Position Reading";
      CM_ SG_ 512 WarningCounter "Total warnings since ECU start time";
      CM_ SG_ 512 LastError "Last error code";
      """)

    signals =
      p
      |> Map.get(:message)
      |> Enum.flat_map(fn m -> m.signals end)
      |> Enum.map(fn s -> s.name end)
      |> Enum.sort()

    assert signals == ["AFR", "LastError", "WarningCounter"]

    comments =
      p
      |> Map.get(:comment)
      |> Enum.map(fn c -> {c.identifier, c.value} end)
      |> Enum.sort_by(fn {k, _} -> k end)

    assert comments == [
             {"AFR", "Current AFR Reading\n"},
             {"LastError", "Last error code"},
             {"VVTPos", "Current VVT Position Reading"},
             {"WarningCounter", "Total warnings since ECU start time"}
           ]
  end
end
