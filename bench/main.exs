Application.ensure_all_started(:address_input)

Benchee.run(
  %{
    "countries/0" => fn -> AddressInput.countries() end,
    "get_country/1" => fn -> AddressInput.get_country("US") end
  },
  memory_time: 2
)
