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
end
