defmodule TestHelpers do
  def dbc(name) do
    Path.join(["test", "fixtures", "#{name}.dbc"])
    |> File.read!()
  end

  # defp message([]), do: nil
  defp message(["message:" | t]), do: t
  defp message([h | t]), do: message(t)

  defp value(kv) do
    String.split(kv, "=") |> List.last()
  end

  defp pad_even(s) do
    l = String.length(s)

    if rem(l, 2) == 0 do
      s
    else
      String.pad_leading(s, l + 1, "0")
    end
  end

  # take the format that the fome java console spits out
  # and turn it into a stream of tuples where
  # {can_id, can_dlc, bytes}
  def txt_frames(name, bus \\ "bus0") do
    Path.join(["test", "fixtures", "#{name}.txt"])
    |> File.stream!(:line)
    |> Stream.map(fn line ->
      line |> String.trim() |> String.split(" ")
    end)
    |> Stream.filter(fn tokens ->
      bus in tokens
    end)
    |> Stream.map(fn tokens ->
      [id_len | bytes] = message(tokens)
      [id, len] = String.split(id_len, "/")

      bin =
        bytes
        |> Enum.map(fn b -> String.pad_leading(b, 2, "0") end)
        |> Enum.map(&Base.decode16!/1)
        |> Enum.reduce(<<>>, fn byte, acc ->
          acc <> byte
        end)

      {
        String.to_integer(pad_even(value(id)), 16),
        String.to_integer(value(len)),
        bin
      }
    end)
  end
end

ExUnit.start()
