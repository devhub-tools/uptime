defmodule Uptime.Tracer do
  @moduledoc false
  use GenServer

  defstruct [:service, :from, :conn, :start, :result]

  defmodule Result do
    @moduledoc false
    defstruct [:dns_done, :connected, :tls_done, :first_byte, :complete, :status_code, :response_body]
  end

  def start_link(service) do
    GenServer.start_link(__MODULE__, service)
  end

  def trace_request(pid) do
    GenServer.call(pid, :trace_request)
  end

  def init(service) do
    {:ok, %__MODULE__{service: service, result: %Result{}}}
  end

  def handle_call(:trace_request, from, state) do
    Process.send_after(self(), :timeout, state.service.timeout_ms)

    :ok = :inet_db.set_lookup([:file, :dns])
    :ok = :inet_db.set_cache_size(0)

    uri = URI.parse(state.service.url)
    scheme = String.to_existing_atom(uri.scheme)

    start = System.monotonic_time()
    self = self()

    {:ok, conn} =
      Mint.HTTP.connect(scheme, uri.host, uri.port,
        trace_fun: fn event ->
          send(self, {:trace, event, System.monotonic_time()})
          :ok
        end
      )

    {:ok, conn, _ref} = Mint.HTTP.request(conn, state.service.method, uri.path, [], "")

    {:noreply, %{state | from: from, conn: conn, start: start}}
  end

  def handle_info({:trace, event, time}, state) do
    duration = System.convert_time_unit(time - state.start, :native, :millisecond)
    {:noreply, %{state | result: %{state.result | event => duration}}}
  end

  def handle_info(:done, state) do
    GenServer.reply(state.from, {:ok, state.result})

    {:stop, :normal, nil}
  end

  def handle_info(:timeout, state) do
    GenServer.reply(state.from, {:error, :timeout})

    {:stop, :normal, nil}
  end

  def handle_info(message, state) do
    # times are set before processing messages to get more accurate timing, they are only set
    # if we actually received a response message

    # only set first_byte on first message that we got a response
    first_byte =
      state.result.first_byte || System.convert_time_unit(System.monotonic_time() - state.start, :native, :millisecond)

    # always set the last message time as complete
    last_message = System.convert_time_unit(System.monotonic_time() - state.start, :native, :millisecond)

    result = %{state.result | first_byte: first_byte, complete: last_message}

    case Mint.HTTP.stream(state.conn, message) do
      {:ok, conn, []} ->
        {:noreply, %{state | conn: conn}}

      {:ok, conn, responses} ->
        case Enum.reverse(responses) do
          [{:done, _ref} | _rest] ->
            %{status_code: status_code, response_body: response_body} = parse_response(responses)
            send(self(), :done)

            {:noreply, %{state | conn: conn, result: %{result | status_code: status_code, response_body: response_body}}}

          _responses ->
            {:noreply, %{state | conn: conn, result: result}}
        end
    end
  end

  defp parse_response(responses) do
    status_code =
      Enum.find_value(
        responses,
        fn
          {:status, _ref, code} -> code
          _other -> false
        end
      )

    response_body =
      Enum.map_join(responses, fn
        {:data, _ref, body} -> body
        _other -> ""
      end)

    %{status_code: status_code, response_body: response_body}
  end
end
