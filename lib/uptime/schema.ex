defmodule Uptime.Schema do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @foreign_key_type :string
      @timestamps_opts [type: :utc_datetime_usec]
    end
  end
end
