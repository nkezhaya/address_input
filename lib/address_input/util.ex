defmodule AddressInput.Util do
  @moduledoc false

  @spec code_to_field(char()) :: AddressInput.Country.field()
  def code_to_field(?N), do: :name
  def code_to_field(?O), do: :organization
  def code_to_field(?A), do: :address
  def code_to_field(?D), do: :dependent_locality
  def code_to_field(?C), do: :sublocality
  def code_to_field(?S), do: :region
  def code_to_field(?Z), do: :postal_code
  def code_to_field(?X), do: :sorting_code

  @doc false
  @spec parse_format(String.t() | nil) :: AddressInput.address_format() | nil
  def parse_format(nil), do: nil

  def parse_format(raw) do
    raw
    |> tokenize([])
    |> Enum.reverse()
  end

  defp tokenize(<<>>, acc), do: acc

  defp tokenize(<<"%", rest::binary>>, acc) do
    case rest do
      <<"%", tail::binary>> ->
        tokenize(tail, append_text("%", acc))

      <<"n", tail::binary>> ->
        tokenize(tail, [:newline | acc])

      <<code, tail::binary>> ->
        field = code_to_field(code)
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
