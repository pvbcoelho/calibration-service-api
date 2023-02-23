defmodule CalibrationServiceApiWeb.CalibrationControllerTest do
  use CalibrationServiceApiWeb.ConnCase

  @valid_user_email "email_test@test.com"
  @invalid_precheck_1_user_email "email_precheck1_false@test.com"

  @timeout_precheck1_user_email "email_precheck1_timeout@test.com"

  @session_precheck_1 "precheck_1"
  @status_finished "finished"

  describe "start calibration process" do
    test "should start a calibration process when a user email is given and the device precheck correctly",
         %{conn: conn} do
      calibration_session_mock =
        get_calibration_session(
          @valid_user_email,
          @session_precheck_1,
          @status_finished
        )

      conn = post(conn, Routes.calibration_path(conn, :start, user_email: @valid_user_email))

      calibration_session = json_response(conn, 200)
      assert calibration_session_mock.user_device == calibration_session["user_device"]
      assert calibration_session_mock.session == calibration_session["session"]
      assert calibration_session_mock.status == calibration_session["status"]
    end

    test "should return an error when device already has an ongoing calibration process", %{
      conn: conn
    } do
      mock_reponse = get_error_message("User already has an on going calibration session")

      post(
        conn,
        Routes.calibration_path(conn, :start, user_email: @valid_user_email)
      )

      conn =
        post(
          conn,
          Routes.calibration_path(conn, :start, user_email: @valid_user_email)
        )

      assert mock_reponse == json_response(conn, 422)
    end

    test "should return an error when device precheck incorrectly", %{conn: conn} do
      mock_reponse = get_fail_message("Precheck 1 failure")

      conn =
        post(
          conn,
          Routes.calibration_path(conn, :start, user_email: @invalid_precheck_1_user_email)
        )

      assert mock_reponse == json_response(conn, 422)
    end

    test "should return an error when device precheck timeout", %{conn: conn} do
      mock_reponse = get_fail_message("Precheck 1 timeout")

      conn =
        post(
          conn,
          Routes.calibration_path(conn, :start, user_email: @timeout_precheck1_user_email)
        )

      assert mock_reponse == json_response(conn, 422)
    end
  end

  describe "get calibration session" do
    test "should return the ongoing calibration session when a valid user email is given", %{
      conn: conn
    } do
      calibration_session_mock =
        get_calibration_session(
          @valid_user_email,
          @session_precheck_1,
          @status_finished
        )

      post(conn, Routes.calibration_path(conn, :start, user_email: @valid_user_email))

      conn =
        get(
          conn,
          Routes.calibration_path(conn, :get_current_session, @valid_user_email)
        )

      calibration_session = json_response(conn, 200)
      assert calibration_session_mock.user_device == calibration_session["user_device"]
      assert calibration_session_mock.session == calibration_session["session"]
      assert calibration_session_mock.status == calibration_session["status"]
    end

    test "should return an error when there is no on going calibration session with the given email",
         %{
           conn: conn
         } do
      conn =
        get(
          conn,
          Routes.calibration_path(conn, :get_current_session, @valid_user_email)
        )

      assert %{"errors" => %{"detail" => "Not Found"}} == json_response(conn, 404)
    end
  end

  defp get_calibration_session(user_email, session, status),
    do: %{
      user_device: user_email,
      session: session,
      status: status
    }

  defp get_fail_message(description),
    do: %{"error" => %{"message" => "Calibration failure", "description" => description}}

  defp get_error_message(description),
    do: %{"error" => %{"message" => "Calibration error", "description" => description}}
end
