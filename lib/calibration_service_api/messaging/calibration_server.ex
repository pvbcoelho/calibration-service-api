defmodule CalibrationServiceApi.Messaging.CalibrationServer do
  use GenServer

  alias CalibrationServiceApi.CalibrationSession
  alias CalibrationServiceApi.DeviceMessages

  require Logger

  @start_precheck_1_command "startPrecheck1"
  @time_out 500

  def start_link(%CalibrationSession{} = init_arg, process_name) do
    GenServer.start_link(__MODULE__, init_arg, name: process_name)
  end

  def init(opts) do
    {:ok, opts}
  end

  def start_process(pid, session) do
    GenServer.call(pid, session)
  end

  def handle_call(:get_current_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(msg, _from, state) do
    try do
      response =
        Task.async(fn -> DeviceMessages.send(state.user_device, @start_precheck_1_command) end)
        |> Task.await(@time_out)

      updated_calibration_session = %CalibrationSession{
        user_device: state.user_device,
        session: msg,
        status: get_correct_status_from_device_response(response)
      }

      {:reply, updated_calibration_session, updated_calibration_session}
    catch
      :exit, {:timeout, _} ->
        updated_calibration_session = %CalibrationSession{
          user_device: state.user_device,
          session: msg,
          status: :timeout
        }

        {:reply, %{"precheck1" => :timeout}, updated_calibration_session}
    end
  end

  def get_current_state(pid) do
    GenServer.call(pid, :get_current_state)
  end

  defp get_correct_status_from_device_response(%{"precheck1" => true}), do: :finished
  defp get_correct_status_from_device_response(%{"precheck1" => false}), do: :calibration_failure
end
