defmodule Canbus.Encode do
  alias Canbus.Dbc
  import Bitwise

  defp pad_leading(%{start_bit: 0}), do: {:ok, <<>>}

  defp pad_leading(%{start_bit: start_bit}) do
    {:ok, <<0::size(start_bit)>>}
  end

  def encode_bits(signal, value, n_bits)
      when is_integer(value) and is_integer(n_bits) and n_bits > 0 do
    {min_value, max_value} = case signal.sign do
      :signed ->
        # Minimum value (e.g., -128 for 8 bits)
        min_value = -1 <<< (n_bits - 1)
        max_value = (1 <<< (n_bits - 1)) - 1
        {min_value, max_value}

      :unsigned ->
        max_value = (1 <<< n_bits) - 1
        {0, max_value}
    end

    if value < min_value or value > max_value do
      {:error, "Value #{value} cannot fit in #{n_bits} bits #{min_value} #{max_value}"}
    else
      whole_bytes = div(n_bits, 8)
      remaining_bits = rem(n_bits, 8)

      unsigned_value =
        case signal.sign do
          :signed when value < 0 ->
            value + (1 <<< n_bits)
          _ ->
            value
        end

      result = encode_little_endian_bits(unsigned_value, whole_bytes, remaining_bits)

      {:ok, result}
    end
  end

  defp encode_little_endian_bits(value, 0, remaining_bits) when remaining_bits > 0 do
    <<value::size(remaining_bits)>>
  end

  defp encode_little_endian_bits(value, whole_bytes, unaligned_bits) do
    bytes =
      for byte_idx <- 0..(whole_bytes - 1) do
        value >>> (byte_idx * 8) &&& 0xFF
      end

    head = :binary.list_to_bin(bytes)

    if unaligned_bits > 0 do
      remaining_value = value >>> (whole_bytes * 8)
      remaining_bin = <<remaining_value::size(unaligned_bits)>>

      head <> remaining_bin
    else
      head
    end
  end

  defp check_signal_range(%{range: {same, same}}, _), do: :ok

  defp check_signal_range(%{range: {min, max}}, value) do
    if value >= min && value <= max do
      :ok
    else
      {:error, "value #{value} is out of range [#{min}|#{max}]"}
    end
  end

  defp apply_offset_scale(%{scale: {nil, _}}, value) do
    {:ok, value}
  end

  defp apply_offset_scale(%{scale: {_, nil}}, value) do
    {:ok, value}
  end

  defp apply_offset_scale(%{scale: {1, 0}}, value) do
    {:ok, value}
  end

  defp apply_offset_scale(%{scale: {scale, offset}}, value) do
    {:ok, trunc(value / scale - offset)}
  end

  defp encode_signal(signal, value) do
    with :ok <- check_signal_range(signal, value),
         {:ok, offset_scaled} <- apply_offset_scale(signal, value) do
      encode_bits(signal, offset_scaled, signal.size)
    end
  end

  def encode(dbc, data) do
    Enum.map(data, fn {signal_name, signal_value} ->
      {Dbc.get_message_for_signal(dbc, signal_name).id, signal_name, signal_value}
    end)
    |> Enum.group_by(fn {can_id, _, _} -> can_id end)
    |> Enum.map(fn {can_id, _values} ->
      message = Map.get(dbc.message, can_id)

      [start_signal | _] = message.signals

      res =
        Enum.reduce(message.signals, pad_leading(start_signal), fn
          _, {:error, _} = e ->
            e

          s, {:ok, acc} ->
            value = Map.get(data, s.name, 0)
            # what to do with missing values

            with {:ok, b} <- encode_signal(s, value) do
              {:ok, acc <> b}
            end
        end)

      with {:ok, bytes} <- res do
        {:ok, {can_id, byte_size(bytes), bytes}}
      end
    end)
  end
end
