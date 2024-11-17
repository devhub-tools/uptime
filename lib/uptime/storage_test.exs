defmodule Uptime.StorageTest do
  use Uptime.DataCase, async: true

  alias Ecto.Association.NotLoaded
  alias Uptime.Storage

  test "get_service!/2" do
    service = insert(:service)

    # first check should be excluded by limit
    insert(:check, service_id: service.id)
    check = insert(:check, service_id: service.id)

    assert %{checks: %NotLoaded{}} = Storage.get_service!([id: service.id], [])
    assert %{checks: %NotLoaded{}} = Storage.get_service!([id: service.id], preload_checks: false)
    assert %{checks: [^check]} = Storage.get_service!([id: service.id], preload_checks: true, limit_checks: 1)
  end
end
