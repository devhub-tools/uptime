defmodule EnvTest do
  use ExUnit.Case, async: true

  alias Uptime.Env
  alias Uptime.Service

  @prefix "UPTIME"

  @test_dir Path.join(File.cwd!(), "test")

  setup do
    Application.put_env(:uptime, :supported_config_dirs, [@test_dir])
  end

  describe "read/1" do
    test "reads config value from secrets file" do
      secret = "secret value"

      :ok =
        @test_dir
        |> Path.join("#{@prefix}_TEST_SECRET")
        |> File.write(secret)

      assert Env.read("TEST_SECRET") == secret
    end

    test "reads config value from environment" do
      option = "value"
      System.put_env("#{@prefix}_TEST_OPTION", option)
      assert Env.read("TEST_OPTION") == option
    end

    test "reads parsed boolean config value from environment" do
      option = "false"
      System.put_env("#{@prefix}_TEST_OPTION", option)
      assert Env.read("TEST_OPTION", :boolean) == false
      option = "False"
      System.put_env("#{@prefix}_TEST_OPTION", option)
      assert Env.read("TEST_OPTION", :boolean) == false
      option = "0"
      System.put_env("#{@prefix}_TEST_OPTION", option)
      assert Env.read("TEST_OPTION", :boolean) == false
      option = "true"
      System.put_env("#{@prefix}_TEST_OPTION", option)
      assert Env.read("TEST_OPTION", :boolean) == true
      option = "TRUE"
      System.put_env("#{@prefix}_TEST_OPTION", option)
      assert Env.read("TEST_OPTION", :boolean) == true
      option = "1"
      System.put_env("#{@prefix}_TEST_OPTION", option)
      assert Env.read("TEST_OPTION", :boolean) == true
    end

    test "reads parsed uri config value from environment" do
      option = "https://github.com"
      System.put_env("#{@prefix}_TEST_OPTION", option)
      assert %URI{host: "github.com"} = Env.read("TEST_OPTION", :uri)
    end

    test "reads parsed config value from config file" do
      username = "username"

      config = """
      ---
      basic_auth_username: #{username}
      test_number: 42
      test_boolean_1: 1
      test_boolean_2: true
      test_boolean_3: 0
      test_boolean_4: false
      test_uri: https://github.com
      """

      :ok =
        @test_dir
        |> Path.join("config.yaml")
        |> File.write(config)

      assert Env.read("BASIC_AUTH_USERNAME") == username
      assert Env.read("test_number") == 42
      assert Env.read("test_number", :integer) == 42
      assert %URI{host: "github.com"} = Env.read("test_uri", :uri)
      assert Env.read("test_boolean_1", :boolean) == true
      assert Env.read("test_boolean_2", :boolean) == true
      assert Env.read("test_boolean_3", :boolean) == false
      assert Env.read("test_boolean_4", :boolean) == false
    end

    test "reads parsed integer config value from environment" do
      option = "42"
      System.put_env("#{@prefix}_TEST_OPTION", option)
      assert Env.read("TEST_OPTION", :integer) == 42
    end

    test "returns empty value if no config option is found" do
      assert Env.read("NONEXISTENT_OPTION") == nil
    end

    test "returns default value if no config option is found" do
      default = "default value"
      assert Env.read("NONEXISTENT_OPTION", :string, default) == default
    end
  end

  describe "has?/1" do
    test "does not find config value if it does not exist" do
      refute Env.has?("NONEXISTENT_OPTION")
    end

    test "finds config value from secrets file" do
      Application.put_env(:uptime, :supported_secrets_dir, @test_dir)
      secret = "secret value"

      :ok =
        @test_dir
        |> Path.join("#{@prefix}_TEST_SECRET")
        |> File.write(secret)

      assert Env.has?("TEST_SECRET")
    end

    test "finds config value from environment" do
      option = "value"
      System.put_env("#{@prefix}_TEST_OPTION", option)
      assert Env.has?("TEST_OPTION")
    end

    test "finds config value from config file" do
      username = "username"

      config = """
      ---
      basic_auth_username: #{username}
      """

      :ok =
        @test_dir
        |> Path.join("config.yaml")
        |> File.write(config)

      assert Env.has?("BASIC_AUTH_USERNAME")
    end
  end

  describe "get_uri_part/2" do
    test "gets uri value from uri struct" do
      option = "https://github.com"
      System.put_env("#{@prefix}_TEST_OPTION", option)
      assert %URI{host: "github.com"} = uri = Env.read("TEST_OPTION", :uri)
      assert "github.com" == Env.get_uri_part(uri, :host)
    end
  end

  describe "read_services/0" do
    test "returns list of valid service attrs from env vars and config file" do
      System.put_env("#{@prefix}_SERVICE_1_NAME", "github")
      System.put_env("#{@prefix}_SERVICE_1_URL", "https://github.com")
      System.put_env("#{@prefix}_SERVICE_1_EXPECTED_STATUS_CODE", "2xx")
      System.put_env("#{@prefix}_SERVICE_2_NAME", "google search")
      System.put_env("#{@prefix}_SERVICE_2_URL", "https://google.com/search")
      System.put_env("#{@prefix}_SERVICE_2_EXPECTED_STATUS_CODE", "200")

      config = """
      ---
      services:
        - name: forums
          url: https://elixirforum.com
          expected_status_code: 2xx
        - name: package manager
          url: https://hex.pm
          expected_status_code: 429
      """

      :ok =
        @test_dir
        |> Path.join("config.yaml")
        |> File.write(config)

      assert [
               %{"name" => "github", "url" => "https://github.com", "expected_status_code" => "2xx"},
               %{"name" => "google search", "url" => "https://google.com/search", "expected_status_code" => "200"},
               %{"name" => "forums", "url" => "https://elixirforum.com", "expected_status_code" => "2xx"},
               %{"name" => "package manager", "url" => "https://hex.pm", "expected_status_code" => "429"}
             ] = services = Env.read_services()

      assert services |> Enum.map(&Service.changeset/1) |> Enum.all?(& &1.valid?)
    end
  end
end
