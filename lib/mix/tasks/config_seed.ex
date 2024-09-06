defmodule Mix.Tasks.ConfigSeed do
  @moduledoc """
  Add services from configuration.
  """

  use Mix.Task

  alias Uptime.Repo

  require Logger

  @requirements ["app.config"]

  @impl Mix.Task
  def run(_args) do
    load()

    :services
    |> Uptime.Env.get()
    |> Enum.map(&save_service/1)
    |> Enum.filter(fn {result, _} -> result == :error end)
    |> Enum.map(fn {_result, changeset} -> changeset_error_to_string(changeset) end)
    |> Enum.each(&Logger.error/1)
  end

  defp load do
    Application.load(:uptime)
    Application.ensure_all_started([:postgrex, :ecto])
    Repo.start_link(pool_size: 2)
  end

  defp save_service(attrs) do
    attrs
    |> Uptime.Service.changeset()
    |> Repo.insert(
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      conflict_target: :slug,
      returning: false
    )
    |> tap(&create_job/1)
  end

  defp create_job({:ok, service}) do
    %{id: service.id} |> Uptime.CheckJob.new(scheduled_at: DateTime.utc_now()) |> Repo.insert()
  end

  defp create_job({:error, _} = result), do: result

  defp changeset_error_to_string(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.reduce("", fn {k, v}, acc ->
      joined_errors = Enum.join(v, "; ")
      "#{acc}#{k}: #{joined_errors}\n"
    end)
  end
end
