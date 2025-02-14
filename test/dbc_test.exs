defmodule DbcTest do
  use ExUnit.Case
  import TestHelpers
  alias Canbus.Dbc, as: D

  # test "can lex" do
  #   assert {:ok, _} = dbc("fome") |> D.lex() |> IO.inspect
  # end

  # test "can parse" do
  #   {:ok, tokens} = dbc("fome") |> D.parse() |> IO.inspect()
  # end

  test "parse version" do

    D.parse("""
    VERSION "x"

    NS_ :
      NS_DESC_
      CM_
      BA_DEF_
      BA_
      VAL_
      CAT_DEF_
      CAT_
      FILTER
      BA_DEF_DEF_
      EV_DATA_
      ENVVAR_DATA_
      SGTYPE_
      SGTYPE_VAL_
      BA_DEF_SGTYPE_
      BA_SGTYPE_
      SIG_TYPE_REF_
      VAL_TABLE_
      SIG_GROUP_
      SIG_VALTYPE_
      SIGTYPE_VALTYPE_
      BO_TX_BU_
      BA_DEF_REL_
      BA_REL_
      BA_DEF_DEF_REL_
      BU_SG_REL_
      BU_EV_REL_
      BU_BO_REL_
      SG_MUL_VAL_


    """) |> IO.inspect()
  end
end
