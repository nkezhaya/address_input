defmodule AddressInput.Application do
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    AddressInput.Util.load_countries()
    Supervisor.start_link([], strategy: :one_for_one, name: AddressInput.Supervisor)
  end
end
