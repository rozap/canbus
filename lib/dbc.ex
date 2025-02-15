defmodule Canbus.Dbc do
  defmodule SyntaxError do
    defstruct [:token, :line, before: nil]
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
            |> Enum.into(%{})
            # TODO: half baked implementation - distinguishing between identifiers and keywords
            # in the lexer cascaded to weirdness here
            |> Map.delete(:symbols)

          {:ok, m}

        {:error, {line, :dbc_parser, [~c"syntax error before: ", before]}} ->
          {:error, %SyntaxError{line: line, before: :erlang.list_to_binary(before)}}
      end
    end
  end
end
