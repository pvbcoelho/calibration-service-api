defmodule CalibrationServiceApi.CalibrationProcess.Precheck2 do
  @moduledoc """
  This module is responsable to handle precheck_2 calibration process
  """

  alias CalibrationServiceApi.CalibrationSession
  alias CalibrationServiceApi.ElixirInterviewStarter
  alias CalibrationServiceApi.Error.ErrorsMessageManager
  alias CalibrationServiceApi.Messaging.CalibrationServer

  @spec start_precheck_2(user_email :: String.t()) ::
          {:error, %{description: String.t(), message: String.t()}}
          | {:ok, CalibrationSession.t()}

  # @spec start_precheck_2(any) :: {:ok, :ok}
  @doc """
  Starts the precheck 2 step of the ongoing `CalibrationSession` for the provided user.

  If the user has no ongoing `CalibrationSession`, their `CalibrationSession` is not done
  with precheck 1, or their calibration session has already completed precheck 2, returns
  an error.
  """
  def start_precheck_2(user_email) do
    response = ElixirInterviewStarter.get_current_session(user_email)

    case response do
      nil ->
        ErrorsMessageManager.get_error_message(
          "User does not have any on going calibration session"
        )

      {:ok, %CalibrationSession{session: :precheck_1, status: :finished}} ->
        start_precheck_2_process(user_email)

      {:ok, %CalibrationSession{session: :precheck_2}} ->
        ErrorsMessageManager.get_error_message("User already has an on going calibration session")

      {:ok, %CalibrationSession{session: :calibrate}} ->
        ErrorsMessageManager.get_error_message("User already has an on going calibration session")

      _ ->
        ErrorsMessageManager.get_failure_message(
          "There is no prechek_1 calibration session with status finished"
        )
    end
  end

  defp start_precheck_2_process(user_email) do
    pid = :global.whereis_name(user_email)

    updated_calibration_session =
      CalibrationSession.get_new_calibration_session(user_email, :pre_check_2, :on_going)

    CalibrationServer.start_process(pid, {:update_state, updated_calibration_session})

    case CalibrationServer.start_process(pid, :precheck_2) do
      %CalibrationSession{status: :finished} ->
        start_calibrate_process(pid, user_email)

      result ->
        GenServer.stop(pid)
        description = ErrorsMessageManager.get_error_description(result)
        ErrorsMessageManager.get_failure_message(description)
    end
  end

  defp start_calibrate_process(pid, user_email) do
    updated_calibration_session =
      CalibrationSession.get_new_calibration_session(user_email, :calibrate, :on_going)

    CalibrationServer.start_process(pid, {:update_state, updated_calibration_session})
    calibrate_result = CalibrationServer.start_process(pid, :calibrate)
    GenServer.stop(pid)

    case calibrate_result do
      %CalibrationSession{status: :finished} = calibrate_success ->
        {:ok, calibrate_success}

      _ ->
        ErrorsMessageManager.get_failure_message("Device could not calibrate")
    end
  end
end
