defmodule Uptime do
  @moduledoc false
  @callback save_check!(Uptime.Service.t()) :: Uptime.Check.t()
  def save_check!(attrs) do
    attrs
    |> Uptime.Check.changeset()
    |> Uptime.Repo.insert!()
  end

  def get_service(id) do
    Uptime.Repo.get(Uptime.Service, id)
  end
end
