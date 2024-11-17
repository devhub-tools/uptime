defmodule UptimeTest do
  use Uptime.DataCase, async: true

  alias Uptime.Storage.Mock

  test "get_service!/2" do
    %{id: service_id} = service = build(:service)

    expect(Mock, :get_service!, fn [id: ^service_id], [] -> service end)

    assert service == Uptime.get_service!(id: service.id)
  end

  test "list_services/1" do
    service = build(:service)

    expect(Mock, :list_services, fn [] -> [service] end)

    assert [service] == Uptime.list_services()
  end

  test "save_check!/1 saves a check" do
    service = build(:service)

    attrs = %{
      service_id: service.id,
      status: :success,
      status_code: 200,
      response_body: "ok",
      dns_time: 10,
      connect_time: 20,
      tls_time: 30,
      first_byte_time: 40,
      request_time: 100
    }

    expect(Mock, :save_check!, fn ^attrs -> build(:check, attrs) end)

    assert %Uptime.Check{status: :success} = Uptime.save_check!(attrs)
  end
end
