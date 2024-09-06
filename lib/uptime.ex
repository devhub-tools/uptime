defmodule Uptime do
  @moduledoc false
  @behaviour __MODULE__

  use Injexor, inject: [Uptime.Storage]

  alias Uptime.Check
  alias Uptime.CheckJob
  alias Uptime.Storage

  @callback get_service!(String.t()) :: Service.t()
  @callback get_service!(String.t(), Keyword.t()) :: Service.t()
  def get_service!(id, opts \\ []) do
    Storage.get_service!(id, opts)
  end

  @callback get_service_by_slug!(String.t()) :: Service.t()
  @callback get_service_by_slug!(String.t(), Keyword.t()) :: Service.t()
  def get_service_by_slug!(slug, opts \\ []) do
    Storage.get_service_by_slug!(slug, opts)
  end

  @callback list_services() :: [Service.t()]
  @callback list_services(Keyword.t()) :: [Service.t()]
  def list_services(opts \\ []) do
    Storage.list_services(opts)
  end

  @callback save_check!(map()) :: Uptime.Check.t()
  def save_check!(attrs) do
    attrs
    |> Storage.save_check!()
    |> tap(&broadcast!/1)
  end

  @callback save_service(map()) :: {:ok, Uptime.Service.t()} | {:error, Ecto.Changeset.t()}
  def save_service(attrs) do
    case Storage.save_service(attrs) do
      {:ok, service} ->
        %{id: service.id} |> CheckJob.new(scheduled_at: DateTime.utc_now()) |> Oban.insert()

      error ->
        error
    end
  end

  @spec subscribe_checks() :: :ok | {:error, term()}
  def subscribe_checks do
    Phoenix.PubSub.subscribe(Uptime.PubSub, check_topic())
  end

  @spec subscribe_checks(String.t()) :: :ok | {:error, term()}
  def subscribe_checks(service_id) do
    Phoenix.PubSub.subscribe(Uptime.PubSub, check_topic(service_id))
  end

  @spec unsubscribe_checks() :: :ok
  def unsubscribe_checks do
    Phoenix.PubSub.unsubscribe(Uptime.PubSub, check_topic())
  end

  @spec unsubscribe_checks(String.t()) :: :ok
  def unsubscribe_checks(service_id) do
    Phoenix.PubSub.unsubscribe(Uptime.PubSub, check_topic(service_id))
  end

  @spec broadcast!(Check.t()) :: :ok
  defp broadcast!(%Check{} = check) do
    Phoenix.PubSub.broadcast!(Uptime.PubSub, check_topic(), {Check, check})
    Phoenix.PubSub.broadcast!(Uptime.PubSub, check_topic(check.service_id), {Check, check})
  end

  @spec check_topic() :: String.t()
  def check_topic, do: "service:all"

  @spec check_topic(String.t()) :: String.t()
  def check_topic(service_id), do: "service:#{service_id}"
end
