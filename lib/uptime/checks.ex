defmodule Uptime.Checks do
  @moduledoc """
  This module defines the Check context layer.
  """

  alias Uptime.Check
  alias Uptime.Service

  @spec success?(Check.t(), Service.t()) :: boolean()
  def success?(%Check{} = check, %Service{} = service) do
    String.to_integer(service.expected_status_code) == check.status_code
  end
end
