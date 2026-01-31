Application.ensure_all_started(:address_input)

Benchee.run(
  %{
    "countries/0" => fn -> AddressInput.countries() end,
    "get_country/1" => fn -> AddressInput.get_country("US") end,
    "load_countries/0" => fn -> AddressInput.Util.load_countries() end
  },
  memory_time: 2
)
