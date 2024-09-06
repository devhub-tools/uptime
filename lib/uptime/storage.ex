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
    %{preload_checks: preload_checks, limit_checks: limit_checks} = service_query_opts(opts)

    from(s in Service, where: s.id == ^id)
    |> maybe_preload_checks(preload_checks, limit_checks)
    |> Repo.one!()
  end

  @callback get_service_by_slug!(String.t(), Keyword.t()) :: Service.t()
  def get_service_by_slug!(slug, opts) do
    %{preload_checks: preload_checks, limit_checks: limit_checks} = service_query_opts(opts)

    from(s in Service, where: s.slug == ^slug)
    |> maybe_preload_checks(preload_checks, limit_checks)
    |> Repo.one!()
  end

  @callback list_services(Keyword.t()) :: [Service.t()]
  def list_services(opts) do
    %{enabled: enabled, preload_checks: preload_checks, limit_checks: limit_checks} = service_query_opts(opts)

    from(Service)
    |> maybe_where(:enabled, enabled)
    |> order_by(asc: :name)
    |> Repo.all()
    |> maybe_preload_checks(preload_checks, limit_checks)
  end

  @spec save_service(map()) :: Service.t()
  def save_service(attrs) do
    attrs
    |> Service.changeset()
    |> Repo.insert(
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      conflict_target: :slug,
      returning: false
    )
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

  @spec service_query_opts(Keyword.t()) :: map()
  defp service_query_opts(opts) do
    opts
    |> Enum.into(@default_opts)
    |> Map.update(:limit_checks, 30, &min(&1, 1000))
  end
end
