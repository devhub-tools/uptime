defmodule Uptime.ServiceTest do
  use ExUnit.Case, async: true

  import Ecto.Changeset

  alias Uptime.Service

  describe "changeset/1" do
    test "valid changeset" do
      changeset =
        Service.changeset(%Service{}, %{
          name: "Example",
          url: "https://example.com",
          expected_status_code: "200",
          expected_response_body: "Example"
        })

      assert changeset.valid?
      assert get_field(changeset, :slug) == "example"

      changeset =
        Service.changeset(%Service{}, %{
          name: """
          MY!@#$%^&*()          Example<>?/;':""web[]{}|_+~`=sit---e
          """,
          url: "https://example.com",
          expected_status_code: "2xx"
        })

      assert changeset.valid?
      assert get_field(changeset, :slug) == "my-examplewebsit-e"
    end
  end
end
