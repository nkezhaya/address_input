defmodule AddressInput.Country do
  @moduledoc """
  Country metadata parsed from the libaddressinput dataset.
  """

  @enforce_keys [
    :id,
    :name,
    :default_language,
    :required_fields,
    :subregions,
    :sublocality_type,
    :subregion_type,
    :postal_code_type,
    :postal_code_regex,
    :address_format,
    :local_address_format
  ]
  defstruct @enforce_keys

  @type field ::
          :name
          | :organization
          | :address
          | :dependent_locality
          | :sublocality
          | :region
          | :postal_code
          | :sorting_code

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          default_language: String.t(),
          required_fields: [field()],
          subregions: [AddressInput.Subregion.t()],
          sublocality_type: String.t() | nil,
          subregion_type: String.t() | nil,
          postal_code_type: String.t() | nil,
          postal_code_regex: Regex.t() | nil,
          address_format: String.t() | nil,
          local_address_format: String.t() | nil
        }
end
