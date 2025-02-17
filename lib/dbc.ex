defmodule Canbus.Dbc do
  defstruct [:message, :version, :nodes, :comment, :bit_timing]

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
                {:message, Enum.map(messages, fn m -> {m.id, m} end) |> Enum.into(%{})}

              {key, value} ->
                {key, value}
            end)
            |> Enum.into(%{})
            # TODO: half baked implementation - distinguishing between identifiers and keywords
            # in the lexer cascaded to weirdness here
            |> Map.delete(:symbols)

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
end
