defmodule Canbus.Dbc do
  defstruct [:message, :version, :nodes, :comment, :bit_timing, signal_to_message: %{}]

  defmodule SyntaxError do
    defstruct [:token, :line, before: nil, tokens: []]
  end

  defmodule UnexpectedValueError do
    defstruct [:target, :path]
  end

  defmodule TypeError do
    defstruct [:target, :reason]
  end

  def lex(content) do
    content
    |> to_charlist
    |> :dbc_lexer.string()
    |> case do
      {:ok, tokens, _} ->
        {:ok, tokens}

      {:error, {line, _, {_, token}}, _} ->
        {:error, %SyntaxError{line: line, token: :erlang.list_to_binary(token)}}
    end
  end

  defp sort_message(m) do
    %{m | signals: Enum.sort_by(m.signals, fn s -> s.start_bit end)}
  end

  def parse(content) do
    with {:ok, tokens} <- lex(content) do
      case :dbc_parser.parse(tokens) do
        {:ok, nodes} ->
          m =
            nodes
            |> Enum.group_by(fn {key, _} -> key end)
            |> Enum.map(fn {key, values} -> {key, Enum.map(values, fn {_key, v} -> v end)} end)
            |> Enum.map(fn
              {:message, messages} ->
                {:message, Enum.map(messages, fn m -> {m.id, sort_message(m)} end) |> Enum.into(%{})}

              {key, value} ->
                {key, value}
            end)
            |> Enum.into(%{})
            # TODO: half baked implementation - distinguishing between identifiers and keywords
            # in the lexer cascaded to weirdness here
            |> Map.delete(:symbols)

          signal_to_message =
            Enum.flat_map(m.message, fn {_can_id, m} ->
              Enum.map(m.signals, fn s ->
                {s.name, m.id}
              end)
            end)
            |> Enum.into(%{})

          m = Map.put(m, :signal_to_message, signal_to_message)

          {:ok, struct(__MODULE__, m)}

        {:error, {line, :dbc_parser, [~c"syntax error before: ", before]}} ->
          l_start = line - 1
          l_end = line + 1

          window =
            Enum.filter(tokens, fn
              t ->
                line =
                  case t do
                    {_, line} -> line
                    {_, line, _} -> line
                  end

                line >= l_start and line <= l_end
            end)

          {:error,
           %SyntaxError{line: line, before: :erlang.list_to_binary(before), tokens: window}}
      end
    end
  end

  def get_signal(%__MODULE__{message: m}, id) do
    Map.get(m, id)
  end

  def get_message_for_signal(%__MODULE__{signal_to_message: lookup} = dbc, signal_name) do
    message_id = Map.get(lookup, signal_name)
    Map.get(dbc.message, message_id)
  end
end
