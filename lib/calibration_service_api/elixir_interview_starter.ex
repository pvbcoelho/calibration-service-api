defmodule CalibrationServiceApi.ElixirInterviewStarter do
  @moduledoc """
  See `README.md` for instructions on how to approach this technical challenge.
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
    get_new_calibration_session(user_email, :pre_check_1, :on_going)
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

  # @spec start_precheck_2(any) :: {:ok, :ok}
  @doc """
  Starts the precheck 2 step of the ongoing `CalibrationSession` for the provided user.

  If the user has no ongoing `CalibrationSession`, their `CalibrationSession` is not done
  with precheck 1, or their calibration session has already completed precheck 2, returns
  an error.
  """

  @spec start_precheck_2(user_email :: String.t()) ::
          {:error, %{description: String.t(), message: String.t()}}
          | {:ok, CalibrationSession.t()}
  def start_precheck_2(user_email) do
    response = get_current_session(user_email)

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
    updated_calibration_session = get_new_calibration_session(user_email, :pre_check_2, :on_going)
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
    updated_calibration_session = get_new_calibration_session(user_email, :calibrate, :on_going)
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

  @spec get_current_session(user_email :: String.t()) :: nil | {:ok, CalibrationSession.t()}
  @doc """
  Retrieves the ongoing `CalibrationSession` for the provided user, if they have one otherwise an error is returned
  """
  def get_current_session(user_email) do
    case :global.whereis_name(user_email) do
      :undefined ->
        nil

      pid ->
        {:ok, CalibrationServer.get_current_state(pid)}
    end
  end

  defp get_new_calibration_session(user_email, session, status),
    do: %CalibrationSession{
      user_device: user_email,
      session: session,
      status: status
    }
end
