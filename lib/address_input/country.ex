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
    :postal_code_type
  ]
  defstruct @enforce_keys

  @type required_field ::
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
          required_fields: [required_field()],
          subregions: [AddressInput.Subregion.t()],
          sublocality_type: String.t() | nil,
          subregion_type: String.t() | nil,
          postal_code_type: String.t() | nil
        }
end
