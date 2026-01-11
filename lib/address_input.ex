defmodule AddressInput do
  @moduledoc """
  High-level API for address metadata derived from the
  [libaddressinput](https://github.com/google/libaddressinput) dataset.

  The module loads a JSON dataset from `priv/metadata.json` (bundled with the
  application) and exposes convenience functions for looking up normalized
  [Country](`AddressInput.Country`) and [Subregion](`AddressInput.Subregion`)
  structs.

  ## Primary entry points

  - `countries/0` returns all available countries sorted by ISO 3166-1 alpha-2
    code. Each country includes parsed subregions.
  - `get_country/1` returns a single country by ISO 3166-1 alpha-2 code (case
    insensitive), or `nil` if it is not present. For compatibility with the raw
    dataset keys it also accepts `"data/XX"` strings.

  ## Country fields

  A [Country](`AddressInput.Country`) includes:

  - `id` - ISO 3166-1 alpha-2 code.
  - `name` - localized display name from the dataset.
  - `default_language` - language code used for labels.
  - `required_fields` - list of required address components as atoms, derived
    from the dataset codes (`N`, `O`, `A`, `D`, `C`, `S`, `Z`, `X`).
  - `subregion_type`, `sublocality_type`, `postal_code_type` - label hints.
  - `subregions` - list of [Subregion](`AddressInput.Subregion`) entries.

  A [Subregion](`AddressInput.Subregion`) includes `id`, `iso_code`, and `name`.

  ## Example

      iex> AddressInput.get_country("US")
      %AddressInput.Country{
        id: "US",
        name: "UNITED STATES",
        default_language: "en",
        required_fields: [:address, :sublocality, :region, :postal_code],
        sublocality_type: "city",
        subregion_type: "state",
        postal_code_type: "zip",
        subregions: [
          %AddressInput.Subregion{id: "AK", iso_code: "AK", name: "Alaska"},
          ...
        ]
      }
      "US"

  """
  alias __MODULE__.{Country, Subregion}

  @external_resource "priv/metadata.json"
  @metadata JSON.decode!(File.read!("#{:code.priv_dir(:address_input)}/metadata.json"))

  @doc """
  Returns the list of available countries as [Country](`AddressInput.Country`) structs.
  """
  @spec countries() :: [Country.t()]
  def countries do
    @metadata
    |> Enum.filter(fn
      {<<"data/", _::binary-size(2)>>, _} -> true
      _ -> false
    end)
    |> Enum.filter(fn
      {_, %{"name" => name}} when is_binary(name) -> true
      _ -> false
    end)
    |> Enum.map(fn {_, metadata} -> build_country!(metadata) end)
    |> Enum.sort_by(& &1.id)
  end

  @doc """
  Returns a [Country](`AddressInput.Country`) by ISO 3166-1 alpha-2 country code.

  Returns `nil` when the country is not found.
  """
  @spec get_country(String.t()) :: Country.t() | nil
  def get_country("data/" <> country), do: get_country(country)

  def get_country(country) do
    # "ZZ" seems to be a blank country
    case @metadata["data/#{String.upcase(country)}"] do
      %{"name" => _} = metadata -> build_country!(metadata)
      _ -> nil
    end
  end

  defp build_country!(metadata) do
    required_fields =
      if required = metadata["require"] do
        required
        |> String.split("", trim: true)
        |> Enum.map(&code_to_field/1)
      else
        []
      end

    subregions =
      split(metadata["sub_keys"])
      |> Enum.map(&parse_subregion!("#{metadata["id"]}/#{&1}"))

    %Country{
      id: metadata["key"],
      name: metadata["name"],
      default_language: metadata["lang"],
      required_fields: required_fields,
      subregion_type: metadata["state_name_type"],
      sublocality_type: metadata["sublocality_name_type"] || "city",
      postal_code_type: metadata["zip_name_type"],
      subregions: subregions
    }
  end

  defp code_to_field("N"), do: :name
  defp code_to_field("O"), do: :organization
  defp code_to_field("A"), do: :address
  defp code_to_field("D"), do: :dependent_locality
  defp code_to_field("C"), do: :sublocality
  defp code_to_field("S"), do: :region
  defp code_to_field("Z"), do: :postal_code
  defp code_to_field("X"), do: :sorting_code

  defp parse_subregion!(id) do
    subregion = @metadata[id]
    <<"data/", _::binary-size(2), "/", id::binary>> = id

    %Subregion{
      id: id,
      iso_code: subregion["isoid"],
      name: subregion["name"] || subregion["key"]
    }
  end

  defp split(term) when is_binary(term), do: String.split(term, "~")
  defp split(_term), do: []
end
