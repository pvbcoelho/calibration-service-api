defmodule CalibrationServiceApi.CalibrationProcess.Precheck1 do
  @moduledoc """
  This module is responsable to start calibration process
  """
  alias CalibrationServiceApi.CalibrationSession
  alias CalibrationServiceApi.Error.ErrorsMessageManager
  alias CalibrationServiceApi.Messaging.CalibrationServer

  @spec start(user_email :: String.t()) ::
          {:error, %{description: String.t(), message: String.t()}}
          | {:ok, CalibrationSession.t()}
  @doc """
  Creates a new `CalibrationSession` for the provided user, starts a `GenServer` process
  for the session, and starts precheck 1.

  If the user already has an ongoing `CalibrationSession`, returns an error.
  """

  def start(user_email) do
    CalibrationSession.get_new_calibration_session(user_email, :pre_check_1, :on_going)
    |> CalibrationServer.start_link({:global, user_email})
    |> start_precheck_1_process()
  end

  defp start_precheck_1_process({:ok, pid}) do
    case CalibrationServer.start_process(pid, :precheck_1) do
      %CalibrationSession{status: :finished} = response ->
        {:ok, response}

      result ->
        GenServer.stop(pid)
        description = ErrorsMessageManager.get_error_description(result)
        ErrorsMessageManager.get_failure_message(description)
    end
  end

  defp start_precheck_1_process({:error, {:already_started, _pid}}),
    do: ErrorsMessageManager.get_error_message("User already has an on going calibration session")
end
