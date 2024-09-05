defmodule UptimeWeb.Utils do
  @moduledoc """
  Utility functions for UptimeWeb.
  """

  @doc """
  Calculate limit of checks to display.

  This leaves width of color bar ~8-9px accounting for page padding and margins between bars.
  """
  def calculate_checks_limit(width) do
    (width / 10 - 10)
    |> Decimal.from_float()
    |> Decimal.round(0)
    |> Decimal.to_integer()
    |> max(20)
  end
end
