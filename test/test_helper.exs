
defmodule TestHelpers do
  def dbc(name) do
    Path.join(["test", "fixtures", name <> ".dbc"])
    |> File.read!
  end
end

ExUnit.start()
