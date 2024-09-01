defmodule Uptime.Services do
  @moduledoc """
  This module defines the Service context layer.
  """

  import Ecto.Query

  alias Ecto.Association.NotLoaded
  alias Uptime.Check
  alias Uptime.Repo
  alias Uptime.Service

  @default_opts %{enabled: true, checks_since: nil}

  @doc """
  Get the service by its ID.

  TODO: I think we should make 'name' unique and get the service by the name in the link.
  Then in the config file we could use the name as the key for the config definition.
  """
  @spec get!(String.t(), Keyword.t()) :: Service.t()
  def get!(id, opts \\ []) do
    %{enabled: enabled, checks_since: checks_since} = Enum.into(opts, @default_opts)

    Service
    |> from()
    |> where([s], s.id == ^id)
    |> maybe_where(:enabled, enabled)
    |> maybe_preload(:checks_since, checks_since)
    |> Repo.one!()
  end

  @doc """
  List all services.
  """
  @spec list(Keyword.t()) :: [Service.t()]
  def list(opts \\ []) do
    %{enabled: enabled, checks_since: checks_since} = Enum.into(opts, @default_opts)

    Service
    |> from()
    |> maybe_where(:enabled, enabled)
    |> maybe_preload(:checks_since, checks_since)
    |> Repo.all()
  end

  @spec maybe_where(Ecto.Query.t(), atom(), any()) :: Ecto.Query.t()
  defp maybe_where(query, :enabled, condition) when not is_nil(condition) do
    where(query, [s], s.enabled == ^condition)
  end

  defp maybe_where(query, _opt, _value), do: query

  @spec maybe_preload(Ecto.Query.t(), atom(), any()) :: Ecto.Query.t()
  defp maybe_preload(query, :checks_since, checks_since) when not is_nil(checks_since) do
    Check
    |> from()
    |> order_by([c], desc: c.inserted_at)
    |> where([c], c.inserted_at >= ^checks_since)
    |> limit(50)
    |> then(&preload(query, checks: ^&1))
  end

  defp maybe_preload(query, _opt, _value), do: query

  @doc """
  Returns _most_ recent field on preloaded checks for a service.
  """
  @spec recent_check_field(Service.t(), atom()) :: Check.t() | nil
  def recent_check_field(%Service{} = service, field) do
    case service.checks do
      %NotLoaded{} ->
        Check
        |> from()
        |> order_by([c], desc: c.inserted_at)
        |> limit(1)
        |> then(&Repo.preload(service, checks: &1))
        |> recent_check_field(field)

      [] ->
        nil

      checks ->
        checks |> Enum.at(0) |> Map.get(field)
    end
  end

  @doc """
  Returns _least_ recent field on preloaded checks for a service.
  """
  @spec first_check_field(Service.t(), atom()) :: Check.t() | nil
  def first_check_field(%Service{} = service, field) do
    case service.checks do
      %NotLoaded{} ->
        Check
        |> from()
        |> order_by([c], desc: c.inserted_at)
        |> limit(1)
        |> then(&Repo.preload(service, checks: &1))
        |> recent_check_field(field)

      [] ->
        nil

      checks ->
        checks |> Enum.reverse() |> Enum.at(0) |> Map.get(field)
    end
  end
end
