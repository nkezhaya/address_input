defmodule AddressInput.Util do
  @moduledoc false

  alias AddressInput.{Country, Subregion}

  @external_resource "priv/metadata.json"

  @doc false
  def load_countries do
    path = "#{:code.priv_dir(:address_input)}/metadata.json"

    metadata =
      path
      |> File.read!()
      |> JSON.decode!()

    countries =
      Enum.reduce(metadata, :gb_trees.empty(), fn
        {<<"data/", code::binary-size(2)>>, %{"name" => name} = country}, tree
        when is_binary(name) ->
          country = build_country!(metadata, country)
          :gb_trees.insert(code, country, tree)

        _, tree ->
          tree
      end)

    sorted =
      countries
      |> :gb_trees.values()
      |> Enum.sort_by(& &1.name)

    :persistent_term.put(:address_input_countries, {countries, sorted})
  end

  defp build_country!(metadata, country) do
    required_fields =
      if required = country["require"] do
        required
        |> String.to_charlist()
        |> Enum.map(&code_to_field/1)
      else
        []
      end

    subregions =
      split(country["sub_keys"])
      |> Enum.map(&parse_subregion!(metadata, "#{country["id"]}/#{&1}"))

    postal_code_regex =
      if zip = country["zip"] do
        Regex.compile!("\\A(?:#{zip})\\z")
      end

    %Country{
      id: country["key"],
      name: country["name"],
      default_language: country["lang"],
      required_fields: required_fields,
      subregion_type: country["state_name_type"],
      sublocality_type: country["sublocality_name_type"] || "city",
      postal_code_type: country["zip_name_type"],
      postal_code_regex: postal_code_regex,
      address_format: parse_format(country["fmt"]),
      local_address_format: parse_format(country["lfmt"]),
      subregions: subregions
    }
  end

  defp parse_subregion!(metadata, <<"data/", _::binary-size(2), "/", subregion_id::binary>> = id) do
    subregion = metadata[id]

    %Subregion{
      id: subregion_id,
      iso_code: subregion["isoid"],
      name: subregion["name"] || subregion["key"]
    }
  end

  defp split(term) when is_binary(term), do: String.split(term, "~")
  defp split(_term), do: []

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
