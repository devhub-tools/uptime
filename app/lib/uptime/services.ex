defmodule Uptime.Services do
  @moduledoc """
  This module defines the Service context layer.
  """

  import Ecto.Query

  alias Uptime.Check
  alias Uptime.Repo
  alias Uptime.Service

  @list_default_opts %{enabled: true, checks_since: nil}

  @spec list(Keyword.t()) :: [Service.t()]
  def list(opts \\ []) do
    %{enabled: enabled, checks_since: checks_since} = Enum.into(opts, @list_default_opts)

    Service
    |> from()
    |> maybe_where(:enabled, enabled)
    |> maybe_preload(:checks_since, checks_since)
    |> Repo.all()
  end

  @spec maybe_where(Ecto.Query.t(), atom(), any()) :: Ecto.Query.t()
  defp maybe_where(query, :enabled, condition) do
    where(query, [s], s.enabled == ^condition)
  end

  defp maybe_where(query, _opt, _value), do: query

  @spec maybe_preload(Ecto.Query.t(), atom(), any()) :: Ecto.Query.t()
  defp maybe_preload(query, :checks_since, checks_since) do
    Check
    |> from()
    |> order_by([c], desc: c.inserted_at)
    |> where([c], c.inserted_at >= ^checks_since)
    |> then(&preload(query, checks: ^&1))
  end

  defp maybe_preload(query, _opt, _value), do: query

  @doc """
  Returns most recent field on preloaded checks for a service.
  """
  @spec recent_check_field(Service.t(), atom()) :: Check.t() | nil
  def recent_check_field(%Service{} = service, field) do
    case service.checks do
      %Ecto.Association.NotLoaded{} ->
        Check
        |> from()
        |> order_by([c], desc: c.inserted_at)
        |> limit(1)
        |> then(&preload(service, checks: ^&1))
        |> recent_check_field(field)

      [] ->
        nil

      checks ->
        checks |> Enum.max_by(& &1.inserted_at) |> Map.get(field)
    end
  end
end
