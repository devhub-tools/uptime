defmodule UptimeWeb.Components.Helpers do
  @moduledoc """
  Component helpers
  """

  @spec unique_id() :: String.t()
  def unique_id do
    16 |> :crypto.strong_rand_bytes() |> Base.encode16()
  end

  def focus_class, do: "focus-visible:ring-ring focus-visible:outline-none focus-visible:ring-1"
end
