defmodule CalibrationServiceApi.Messaging.CalibrationServer do
  use GenServer

  alias CalibrationServiceApi.CalibrationSession
  alias CalibrationServiceApi.DeviceMessages

  require Logger

  @time_out Application.compile_env(:calibration_service_api, :timeouts)[:precheks]
  @time_out_calibrate Application.compile_env(:calibration_service_api, :timeouts)[:calibration]

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

  def handle_call({:update_state, %CalibrationSession{} = new_calibration_session}, _from, _state) do
    {:reply, new_calibration_session, new_calibration_session}
  end

  def handle_call(msg, _from, state) when msg in [:precheck_1, :precheck_2, :calibrate] do
    try do
      command_message = get_command_message(msg)
      device_response = send_device_message(state.user_device, command_message)
      updated_calibration_session = get_new_state(state.user_device, msg, device_response)
      {:reply, updated_calibration_session, updated_calibration_session}
    catch
      :exit, {:timeout, _} ->
        correct_key = get_correct_key(msg)
        updated_calibration_session = get_new_state(state.user_device, msg, :timeout)
        {:reply, %{correct_key => :timeout}, updated_calibration_session}
    end
  end

  def get_current_state(pid) do
    GenServer.call(pid, :get_current_state)
  end

  defp get_new_state(user_device, msg, device_response) do
    %CalibrationSession{
      user_device: user_device,
      session: msg,
      status: DeviceMessages.get_correct_status_from_device_response(device_response)
    }
  end

  defp get_command_message(:precheck_1), do: "startPrecheck1"
  defp get_command_message(:precheck_2), do: "startPrecheck2"
  defp get_command_message(:calibrate), do: "calibrate"

  defp send_device_message(user_device, command_message) do
    time_out =
      case command_message do
        "calibrate" -> @time_out_calibrate
        _ -> @time_out
      end

    Task.async(fn -> DeviceMessages.send(user_device, command_message) end)
    |> Task.await(time_out)
  end

  defp get_correct_key(:precheck_1), do: "precheck1"
  defp get_correct_key(:precheck_2), do: "precheck2"
  defp get_correct_key(:calibrate), do: "calibrate"
end
