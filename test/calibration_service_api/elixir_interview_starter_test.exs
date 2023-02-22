defmodule CalibrationServiceApi.ElixirInterviewStarterTest do
  use ExUnit.Case

  alias CalibrationServiceApi.CalibrationSession
  alias CalibrationServiceApi.ElixirInterviewStarter

  @valid_user_email "email_test@teste.com"
  @invalid_precheck_1_user_email "email_precheck1.false@test.com"

  @timeout_user_email "email_timeout@teste.com"

  @session_precheck_1 :precheck_1
  @status_finished :finished

  test "it can go through the whole flow happy path" do
  end

  test "start/1 creates a new calibration session and starts precheck 1" do
    calibration_session_test =
      get_calibration_session(@valid_user_email, @session_precheck_1, @status_finished)

    assert {:ok, calibration_session_test} == ElixirInterviewStarter.start(@valid_user_email)
  end

  test "start/1 returns an error if the provided user already has an ongoing calibration session" do
    calibration_session_test =
      get_calibration_session(@valid_user_email, @session_precheck_1, @status_finished)

    assert {:ok, calibration_session_test} == ElixirInterviewStarter.start(@valid_user_email)

    assert get_error_message("Calibration session already on going") ==
             ElixirInterviewStarter.start(@valid_user_email)
  end

  test "start/1 returns an error if the device does not precheck correctly in precheck_1 session" do
    assert get_fail_message("Precheck 1 failure") ==
             ElixirInterviewStarter.start(@invalid_precheck_1_user_email)
  end

  test "start/1 returns an error if a timeout occurs during the precheck_1 calibration session" do
    assert get_fail_message("Precheck 1 timeout") ==
             ElixirInterviewStarter.start(@timeout_user_email)
  end

  # test "start_precheck_2/1 starts precheck 2" do
  # end

  # test "start_precheck_2/1 returns an error if the provided user does not have an ongoing calibration session" do
  # end

  # test "start_precheck_2/1 returns an error if the provided user's ongoing calibration session is not done with precheck 1" do
  # end

  # test "start_precheck_2/1 returns an error if the provided user's ongoing calibration session is already done with precheck 2" do
  # end

  # test "get_current_session/1 returns the provided user's ongoing calibration session" do
  # end

  # test "get_current_session/1 returns nil if the provided user has no ongoing calibrationo session" do
  # end

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
