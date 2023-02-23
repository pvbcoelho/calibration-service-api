defmodule CalibrationServiceApi.DeviceMessages do
  @moduledoc """
  You shouldn't need to mofidy this module.

  This module provides an interface for mock-sending commands to devices.
  """

  @spec send(user_email :: String.t(), command :: String.t()) :: map()
  @doc """
  Pretends to send the provided command to the Sutro Smart Monitor belonging to the
  provided user, which for the purposes of this challenge will always succeed.
  """

  def send("email_precheck1_timeout@test.com", "startPrecheck1") do
    :timer.sleep(1_000)
    :nok
  end

  def send("email_precheck2_timeout@test.com", "startPrecheck2") do
    :timer.sleep(1_000)
    :nok
  end

  def send("email_calibrate_timeout@test.com", "calibrate") do
    :timer.sleep(1_000)
    :nok
  end

  def send("email_precheck1_false@test.com", "startPrecheck1"), do: %{"precheck1" => false}
  def send(_user_email, "startPrecheck1"), do: %{"precheck1" => true}

  def send("email_precheck2_water_false@test.com", "startPrecheck2"),
    do: %{"cartridgeStatus" => true, "submergedInWater" => false}

  def send("email_precheck2_cartridge_false@test.com", "startPrecheck2"),
    do: %{"cartridgeStatus" => false, "submergedInWater" => true}

  def send("email_precheck2_water_and_cartridge_false@test.com", "startPrecheck2"),
    do: %{"cartridgeStatus" => false, "submergedInWater" => false}

  def send(_user_email, "startPrecheck2"),
    do: %{"cartridgeStatus" => true, "submergedInWater" => true}

  def send("email_calibrate_false@test.com", "calibrate"), do: %{"calibrated" => false}
  def send(_user_email, "calibrate"), do: %{"calibrated" => true}

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

  def get_correct_status_from_device_response(%{"calibrated" => true}), do: :finished
  def get_correct_status_from_device_response(%{"calibrated" => false}), do: :calibration_failure
end
