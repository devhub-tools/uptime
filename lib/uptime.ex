defmodule Uptime do
  @moduledoc false
  @behaviour __MODULE__

  use Injexor, inject: [Uptime.Storage]

  alias Uptime.Storage

  @callback get_service!(String.t()) :: Service.t()
  @callback get_service!(String.t(), Keyword.t()) :: Service.t()
  def get_service!(id, opts \\ []) do
    Storage.get_service!(id, opts)
  end

  @callback list_services() :: [Service.t()]
  @callback list_services(Keyword.t()) :: [Service.t()]
  def list_services(opts \\ []) do
    Storage.list_services(opts)
  end

  @callback save_check!(map()) :: Uptime.Check.t()
  def save_check!(attrs) do
    Storage.save_check!(attrs)
  end
end
