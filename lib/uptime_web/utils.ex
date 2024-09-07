defmodule UptimeWeb.Utils do
  @moduledoc """
  Utility functions for UptimeWeb.
  """

  @doc """
  Calculate limit of checks to display.

  This leaves width of color bar ~8-9px accounting for page padding and margins between bars.

  Our goal is to display as many bars as possible.
  There are visual distortions when the bars are too small.
  """
  def calculate_checks_limit(width) do
    # - page padding (x2)
    (width / 8 - 24 * 2)
    |> Decimal.from_float()
    |> Decimal.round(0)
    |> Decimal.to_integer()
    |> max(20)
  end
end
