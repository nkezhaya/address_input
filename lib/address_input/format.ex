defmodule AddressInput.Format do
  @moduledoc """
  Parsed address format templates based on the libaddressinput `fmt` fields.

  A `%AddressInput.Format{}` stores a tokenized representation of the raw
  template string. You can obtain one via `AddressInput.address_format/2` and
  then inspect the tokens to build rendering or validation helpers without
  re-parsing the source template.

  ## Tokens

  The `:tokens` list preserves the order of the original template and contains
  one of:

  - `{:field, field}` - a required address component, where `field` is one of
    the `AddressInput.Country.required_field()` atoms.
  - `{:text, string}` - literal text from the template.
  - `:newline` - a line break marker (the `%n` code in the dataset).

  Unknown format codes raise at parse time to surface dataset issues early.
  """

  alias AddressInput.{Country, Util}

  @type token ::
          {:field, Country.field()}
          | {:text, String.t()}
          | :newline

  @type t :: %__MODULE__{
          tokens: [token()]
        }

  defstruct [:tokens]

  @doc false
  @spec parse(String.t()) :: t()
  def parse(raw) do
    tokens =
      raw
      |> tokenize([])
      |> Enum.reverse()

    %__MODULE__{tokens: tokens}
  end

  @doc false
  @spec fields(t()) :: [Country.field()]
  def fields(%__MODULE__{tokens: tokens}) do
    Enum.flat_map(tokens, fn
      {:field, field} -> [field]
      _ -> []
    end)
  end

  defp tokenize(<<>>, acc), do: acc

  defp tokenize(<<"%", rest::binary>>, acc) do
    case rest do
      <<"%", tail::binary>> ->
        tokenize(tail, append_text("%", acc))

      <<"n", tail::binary>> ->
        tokenize(tail, [:newline | acc])

      <<code, tail::binary>> ->
        field = Util.code_to_field(code)
        tokenize(tail, [{:field, field} | acc])

      <<>> ->
        append_text("%", acc)
    end
  end

  defp tokenize(<<char::utf8, tail::binary>>, acc) do
    tokenize(tail, append_text(<<char::utf8>>, acc))
  end

  defp append_text(text, [{:text, existing} | rest]) do
    [{:text, existing <> text} | rest]
  end

  defp append_text(text, acc), do: [{:text, text} | acc]
end
