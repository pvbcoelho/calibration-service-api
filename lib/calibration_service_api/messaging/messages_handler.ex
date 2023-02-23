defmodule CalibrationServiceApi.Messaging.MessagesHandler do
  @moduledoc """
  This module is responsable to handle messages.
  """

  def get_correct_status_from_device_response(%{"precheck1" => true}), do: :finished
  def get_correct_status_from_device_response(%{"precheck1" => false}), do: :calibration_failure
  def get_correct_status_from_device_response(:timeout), do: :timeout

  def get_correct_status_from_device_response(%{
        "cartridgeStatus" => cartridgeStatus,
        "submergedInWater" => submergedInWater
      }) do
    case {cartridgeStatus, submergedInWater} do
      {true, true} -> :finished
      {true, false} -> :submerged_in_water_error
      {false, true} -> :cartridge_status_error
      {false, false} -> :cartridge_status_and_submerged_in_water_error
    end
  end

  def get_command_message(:precheck_1), do: "startPrecheck1"
  def get_command_message(:precheck_2), do: "startPrecheck2"
  def get_command_message(:calibrate), do: "calibrate"
end
