defmodule Uptime.Storage do
  @moduledoc false
  import Ecto.Query

  alias Uptime.Check
  alias Uptime.Repo
  alias Uptime.Service

  @default_opts %{enabled: true, preload_checks: false}

  ###
  ### Services
  ###
  @spec get_service!(String.t(), Keyword.t()) :: Service.t()
  def get_service!(id, opts) do
    %{preload_checks: preload_checks} = Enum.into(opts, @default_opts)

    from(s in Service, where: s.id == ^id)
    |> maybe_preload_checks(preload_checks)
    |> Repo.one!()
  end

  @spec list_services(Keyword.t()) :: [Service.t()]
  def list_services(opts) do
    %{enabled: enabled, preload_checks: preload_checks} = Enum.into(opts, @default_opts)

    from(Service)
    |> maybe_where(:enabled, enabled)
    |> Repo.all()
    |> maybe_preload_checks(preload_checks)
  end

  ###
  ### Checks
  ###
  @callback save_check!(Uptime.Service.t()) :: Uptime.Check.t()
  def save_check!(attrs) do
    attrs
    |> Uptime.Check.changeset()
    |> Uptime.Repo.insert!()
  end

  ###
  ### Utils
  ###
  @spec maybe_where(Ecto.Query.t(), atom(), any()) :: Ecto.Query.t()
  defp maybe_where(query, field, condition) when not is_nil(condition) do
    from query, where: ^[{field, condition}]
  end

  defp maybe_where(query, _opt, _value), do: query

  @spec maybe_preload_checks([Service.t()] | Ecto.Query.t(), boolean()) :: Ecto.Query.t()
  defp maybe_preload_checks(services, true) when is_list(services) do
    recent_checks = from(c in Check, order_by: [desc: c.inserted_at], limit: 50)

    Enum.map(services, fn service ->
      Repo.preload(service, checks: recent_checks)
    end)
  end

  defp maybe_preload_checks(query, true) do
    recent_checks = from(c in Check, order_by: [desc: c.inserted_at], limit: 50)

    from query, preload: [checks: ^recent_checks]
  end

  defp maybe_preload_checks(query, _preload_checks), do: query
end
