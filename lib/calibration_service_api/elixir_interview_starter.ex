defmodule CalibrationServiceApi.ElixirInterviewStarter do
  @moduledoc """
  See `README.md` for instructions on how to approach this technical challenge.
  """

  alias CalibrationServiceApi.CalibrationProcess.Precheck1
  alias CalibrationServiceApi.CalibrationProcess.Precheck2
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
    Precheck1.start(user_email)
  end

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
    Precheck2.start_precheck_2(user_email)
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
end
