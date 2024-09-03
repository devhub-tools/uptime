defmodule Uptime.Storage do
  @moduledoc false
  @behaviour __MODULE__

  import Ecto.Query

  alias Uptime.Check
  alias Uptime.Repo
  alias Uptime.Service

  @default_opts %{enabled: true, preload_checks: false, limit_checks: 30}

  ###
  ### Services
  ###
  @callback get_service!(String.t(), Keyword.t()) :: Service.t()
  def get_service!(id, opts) do
    %{preload_checks: preload_checks, limit_checks: limit_checks} = Enum.into(opts, @default_opts)

    from(s in Service, where: s.id == ^id)
    |> maybe_preload_checks(preload_checks, limit_checks)
    |> Repo.one!()
  end

  @callback list_services(Keyword.t()) :: [Service.t()]
  def list_services(opts) do
    %{enabled: enabled, preload_checks: preload_checks, limit_checks: limit_checks} = Enum.into(opts, @default_opts)

    from(Service)
    |> maybe_where(:enabled, enabled)
    |> Repo.all()
    |> maybe_preload_checks(preload_checks, limit_checks)
  end

  ###
  ### Checks
  ###
  @callback save_check!(map()) :: Check.t()
  def save_check!(attrs) do
    attrs
    |> Check.changeset()
    |> Repo.insert!()
  end

  ###
  ### Utils
  ###
  @spec maybe_where(Ecto.Query.t(), atom(), any()) :: Ecto.Query.t()
  defp maybe_where(query, _opt, nil), do: query

  defp maybe_where(query, field, condition) do
    from query, where: ^[{field, condition}]
  end

  @spec maybe_preload_checks([Service.t()] | Ecto.Query.t(), boolean(), integer()) :: Ecto.Query.t()
  defp maybe_preload_checks(services, true, limit_checks) when is_list(services) do
    recent_checks = from(c in Check, order_by: [desc: c.inserted_at], limit: ^limit_checks)
    Enum.map(services, &Repo.preload(&1, checks: recent_checks))
  end

  defp maybe_preload_checks(query, true, limit_checks) do
    recent_checks = from(c in Check, order_by: [desc: c.inserted_at], limit: ^limit_checks)
    from query, preload: [checks: ^recent_checks]
  end

  defp maybe_preload_checks(query, _preload_checks, _limit), do: query
end
