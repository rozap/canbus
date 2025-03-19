defmodule Canbus.Decode do
  alias Canbus.Dbc

  defp decode_bytes(b, size, :unsigned, :little) do
    <<p::little-unsigned-integer-size(^size), _rest::bits>> = b
    p
  end

  defp decode_bytes(b, size, :signed, :little) do
    <<p::little-signed-integer-size(^size), _rest::bits>> = b
    p
  end

  # TODO: i don't think big endian decoders work...
  # there is some cursed byte fiddling involved
  defp decode_bytes(b, size, :unsigned, :big) do
    <<p::big-unsigned-integer-size(^size), _rest::bits>> = b
    p
  end

  defp decode_bytes(b, size, :signed, :big) do
    <<p::big-signed-integer-size(^size), _rest::bits>> = b
    p
  end

  defp pop([], _), do: []

  defp pop([s | rest_signals], bytes) do
    value =
      try do
        seeked_bytes =
          case s.start_bit do
            0 ->
              bytes

            start ->
              <<_ignore::bits-size(^start), seek::bits>> = bytes
              seek
          end

        decode_bytes(
          seeked_bytes,
          s.size,
          s.sign,
          s.endianness
        )
      rescue
        e ->
          # Say something useful about which signal
          # is borked
          reraise e, __STACKTRACE__
      end

    [{s, value} | pop(rest_signals, bytes)]
  end

  defp to_physical({s = %{scale: {scale, offset}}, value}) do
    {s.name, offset + value * scale}
  end

  def decode(dbc, {id, _dlc, bytes} = _frame) do
    %{signals: signals} = Dbc.get_signal(dbc, id)
    # TODO: better error handling
    res = pop(signals, bytes) |> Enum.map(&to_physical/1) |> Enum.into(%{})
    {:ok, res}
  end

  def decode!(dbc, f) do
    {:ok, res} = decode(dbc, f)
    res
  end
end
