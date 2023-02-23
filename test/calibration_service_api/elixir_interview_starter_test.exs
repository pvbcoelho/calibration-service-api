defmodule CalibrationServiceApi.ElixirInterviewStarterTest do
  use ExUnit.Case

  alias CalibrationServiceApi.CalibrationSession
  alias CalibrationServiceApi.ElixirInterviewStarter
  alias CalibrationServiceApi.Messaging.CalibrationServer

  @valid_user_email "email_test@test.com"

  @invalid_precheck_1_user_email "email_precheck1_false@test.com"
  @invalid_precheck_2_water_user_email "email_precheck2_water_false@test.com"
  @invalid_precheck_2_cartridge_user_email "email_precheck2_cartridge_false@test.com"
  @invalid_precheck_2_water_and_cartridge_user_email "email_precheck2_water_and_cartridge_false@test.com"
  @invalid_calibrate_user_email "email_calibrate_false@test.com"

  @timeout_precheck_1_user_email "email_precheck1_timeout@test.com"
  @timeout_precheck_2_user_email "email_precheck2_timeout@test.com"
  @timeout_calibrate_user_email "email_calibrate_timeout@test.com"

  @session_precheck_1 :precheck_1
  @session_precheck_2 :precheck_2
  @session_calibrate :calibrate

  @status_finished :finished
  @status_on_going :on_going

  describe "start calibration process" do
    test "start/1 creates a new calibration session and starts precheck 1" do
      calibration_session_test =
        get_calibration_session(@valid_user_email, @session_precheck_1, @status_finished)

      assert {:ok, calibration_session_test} == ElixirInterviewStarter.start(@valid_user_email)
    end

    test "start/1 returns an error if the provided user already has an ongoing calibration session" do
      calibration_session_test =
        get_calibration_session(@valid_user_email, @session_precheck_1, @status_finished)

      assert {:ok, calibration_session_test} == ElixirInterviewStarter.start(@valid_user_email)

      assert get_error_message("User already has an on going calibration session") ==
               ElixirInterviewStarter.start(@valid_user_email)
    end

    test "start/1 returns an error if the device does not precheck correctly in precheck_1 session" do
      assert get_fail_message("Precheck 1 failure") ==
               ElixirInterviewStarter.start(@invalid_precheck_1_user_email)
    end

    test "start/1 returns an error if a timeout occurs during the precheck_1 calibration session" do
      assert get_fail_message("Precheck 1 timeout") ==
               ElixirInterviewStarter.start(@timeout_precheck_1_user_email)
    end
  end

  describe "start prechek_2 calibration process" do
    test "start_precheck_2/1 starts precheck 2" do
      calibration_session_test =
        get_calibration_session(@valid_user_email, @session_calibrate, @status_finished)

      ElixirInterviewStarter.start(@valid_user_email)

      assert {:ok, calibration_session_test} ==
               ElixirInterviewStarter.start_precheck_2(@valid_user_email)
    end

    test "start_precheck_2/1 returns an error if the provided user does not have an ongoing calibration session" do
      description = "User does not have any on going calibration session"

      assert get_error_message(description) ==
               ElixirInterviewStarter.start_precheck_2(@valid_user_email)
    end

    test "start_precheck_2/1 returns an error when precheck 2 `submergedInWater` fail" do
      ElixirInterviewStarter.start(@invalid_precheck_2_water_user_email)
      description = "Error `submergedInWater`"

      assert get_fail_message(description) ==
               ElixirInterviewStarter.start_precheck_2(@invalid_precheck_2_water_user_email)
    end

    test "start_precheck_2/1 returns an error when precheck 2 `cartridgeStatus` fail" do
      ElixirInterviewStarter.start(@invalid_precheck_2_cartridge_user_email)
      description = "Error `cartridgeStatus`"

      assert get_fail_message(description) ==
               ElixirInterviewStarter.start_precheck_2(@invalid_precheck_2_cartridge_user_email)
    end

    test "start_precheck_2/1 returns an error when precheck 2 `submergedInWater` and `cartridgeStatus` fail" do
      ElixirInterviewStarter.start(@invalid_precheck_2_water_and_cartridge_user_email)
      description = "Error `submergedInWater` and `cartridgeStatus`"

      assert get_fail_message(description) ==
               ElixirInterviewStarter.start_precheck_2(
                 @invalid_precheck_2_water_and_cartridge_user_email
               )
    end

    test "start_precheck_2/1 returns an error if the provided user's ongoing calibration session is not done with precheck 1" do
      ElixirInterviewStarter.start(@valid_user_email)
      pid = :global.whereis_name(@valid_user_email)

      updated_calibration_session =
        get_calibration_session(@valid_user_email, @session_precheck_1, @status_on_going)

      CalibrationServer.start_process(pid, {:update_state, updated_calibration_session})

      description = "There is no prechek_1 calibration session with status finished"

      assert get_fail_message(description) ==
               ElixirInterviewStarter.start_precheck_2(@valid_user_email)
    end

    test "start_precheck_2/1 returns an error if the provided user's ongoing calibration session is already done with precheck 2" do
      ElixirInterviewStarter.start(@valid_user_email)
      pid = :global.whereis_name(@valid_user_email)

      updated_calibration_session =
        get_calibration_session(@valid_user_email, @session_precheck_2, @status_on_going)

      CalibrationServer.start_process(pid, {:update_state, updated_calibration_session})

      description = "User already has an on going calibration session"

      assert get_error_message(description) ==
               ElixirInterviewStarter.start_precheck_2(@valid_user_email)
    end

    test "start_precheck_2/1 returns an error when calibrate process fail" do
      ElixirInterviewStarter.start(@invalid_calibrate_user_email)
      description = "Device could not calibrate"

      assert get_fail_message(description) ==
               ElixirInterviewStarter.start_precheck_2(@invalid_calibrate_user_email)
    end

    test "start_precheck_2/1 returns an error if a timeout occurs during the precheck_2 calibration session" do
      ElixirInterviewStarter.start(@timeout_precheck_2_user_email)
      description = "Precheck 2 timeout"

      assert get_fail_message(description) ==
               ElixirInterviewStarter.start_precheck_2(@timeout_precheck_2_user_email)
    end

    test "start_precheck_2/1 returns an error if a timeout occurs during the calibrate session" do
      ElixirInterviewStarter.start(@timeout_calibrate_user_email)
      description = "Device could not calibrate"

      assert get_fail_message(description) ==
               ElixirInterviewStarter.start_precheck_2(@timeout_calibrate_user_email)
    end
  end

  describe "get current calibration session" do
    test "get_current_session/1 returns the provided user's ongoing calibration session" do
      calibration_session_test =
        get_calibration_session(@valid_user_email, @session_precheck_1, @status_finished)

      ElixirInterviewStarter.start(@valid_user_email)

      assert {:ok, calibration_session_test} ==
               ElixirInterviewStarter.get_current_session(@valid_user_email)
    end

    test "get_current_session/1 returns error if the provided user has no ongoing calibrationo session" do
      assert nil == ElixirInterviewStarter.get_current_session(@valid_user_email)
    end
  end

  defp get_calibration_session(user_email, session, status),
    do: %CalibrationSession{
      user_device: user_email,
      session: session,
      status: status
    }

  defp get_fail_message(description),
    do: {:error, %{message: "Calibration failure", description: description}}

  defp get_error_message(description),
    do: {:error, %{message: "Calibration error", description: description}}
end
