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

      {:error, {line, _, {_, token}}, _} = wut ->
        IO.inspect wut
        {:error, %SyntaxError{line: line, token: :erlang.list_to_binary(token)}}
    end
  end

  def parse(content) do
    with {:ok, tokens} <- lex(content) do
      case :dbc_parser.parse(tokens) do
        {:ok, _} = ok ->
          ok

        {:error, {_, :dbc_parser, [~c"syntax error before: ", before]}} ->
          {:error, %SyntaxError{before: :erlang.list_to_binary(before)}}
      end
    end
  end
end
