defmodule CalibrationServiceApi.ElixirInterviewStarter do
  @moduledoc """
  See `README.md` for instructions on how to approach this technical challenge.
  """

  alias CalibrationServiceApi.CalibrationSession
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
    get_new_calibration_session(user_email)
    |> CalibrationServer.start_link({:global, user_email})
    |> start_calibration_process()
  end

  defp get_new_calibration_session(user_email),
    do: %CalibrationSession{
      user_device: user_email,
      session: :pre_check_1,
      status: :on_going
    }

  defp start_calibration_process({:ok, pid}) do
    case CalibrationServer.start_process(pid, :precheck_1) do
      %CalibrationSession{status: :finished} = response ->
        {:ok, response}

      %CalibrationSession{status: :calibration_failure} ->
        GenServer.stop(pid)
        {:error, %{message: "Calibration failure", description: "Precheck 1 failure"}}

      %{"precheck1" => :timeout} ->
        GenServer.stop(pid)
        {:error, %{message: "Calibration failure", description: "Precheck 1 timeout"}}
    end
  end

  defp start_calibration_process({:error, {:already_started, _pid}}),
    do:
      {:error,
       %{message: "Calibration error", description: "Calibration session already on going"}}

  @spec start_precheck_2(any) :: {:ok, :ok}
  @doc """
  Starts the precheck 2 step of the ongoing `CalibrationSession` for the provided user.

  If the user has no ongoing `CalibrationSession`, their `CalibrationSession` is not done
  with precheck 1, or their calibration session has already completed precheck 2, returns
  an error.
  """
  def start_precheck_2(_user_email) do
    {:ok, :ok}
  end

  @spec get_current_session(user_email :: String.t()) ::
          nil
          | {:ok, CalibrationSession.t()}
  @doc """
  Retrieves the ongoing `CalibrationSession` for the provided user, if they have one otherwise an error is returned
  """
  def get_current_session(user_email) do
    case :global.whereis_name(user_email) do
      :undefined -> nil
      pid ->
        {:ok, CalibrationServer.get_current_state(pid)}
    end
  end
end
