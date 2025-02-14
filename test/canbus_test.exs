defmodule CanbusTest do
  use ExUnit.Case
  doctest Canbus

  test "greets the world" do
    assert Canbus.hello() == :world
  end
end
