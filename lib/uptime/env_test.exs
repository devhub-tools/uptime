defmodule Uptime.EnvTest do
  use ExUnit.Case, async: true

  @prefix "UPTIME"

  @test_dir Path.join(File.cwd!(), "test")

  describe "read/1" do
    test "reads config value from secrets file" do
      Application.put_env(:uptime, :supported_secrets_dir, @test_dir)
      secret = "secret value"

      :ok =
        @test_dir
        |> Path.join("#{@prefix}_TEST_SECRET")
        |> File.write(secret)

      assert Uptime.Env.read("TEST_SECRET") == secret
    end

    test "reads config value from environment" do
      option = "value"
      System.put_env("#{@prefix}_TEST_OPTION", option)
      assert Uptime.Env.read("TEST_OPTION") == option
    end

    test "reads config value from config file" do
      Application.put_env(:uptime, :supported_config_dirs, [@test_dir])
      username = "username"

      config = """
      ---
      basic_auth_username: #{username}
      """

      :ok =
        @test_dir
        |> Path.join("config.yaml")
        |> File.write(config)

      assert Uptime.Env.read("BASIC_AUTH_USERNAME") == username
    end

    test "returns empty value if no config option is found" do
      assert Uptime.Env.read("NONEXISTENT_OPTION") == nil
    end
  end

  describe "has?/1" do
    test "does not find config value if it does not exist" do
      refute Uptime.Env.has?("NONEXISTENT_OPTION")
    end

    test "finds config value from secrets file" do
      Application.put_env(:uptime, :supported_secrets_dir, @test_dir)
      secret = "secret value"

      :ok =
        @test_dir
        |> Path.join("#{@prefix}_TEST_SECRET")
        |> File.write(secret)

      assert Uptime.Env.has?("TEST_SECRET")
    end

    test "finds config value from environment" do
      option = "value"
      System.put_env("#{@prefix}_TEST_OPTION", option)
      assert Uptime.Env.has?("TEST_OPTION")
    end

    test "finds config value from config file" do
      Application.put_env(:uptime, :supported_config_dirs, [@test_dir])
      username = "username"

      config = """
      ---
      basic_auth_username: #{username}
      """

      :ok =
        @test_dir
        |> Path.join("config.yaml")
        |> File.write(config)

      assert Uptime.Env.has?("BASIC_AUTH_USERNAME")
    end
  end
end
