defmodule CalibrationServiceApi.Error.ErrorsMessageManager do
  @moduledoc """
  This module is responsable to handle errors messages.
  """

  alias CalibrationServiceApi.CalibrationSession

  @spec get_failure_message(description :: String.t()) ::
          {:error, %{description: String.t(), message: String.t()}}
  def get_failure_message(description) do
    {:error, %{message: "Calibration failure", description: description}}
  end

  @spec get_error_message(description :: String.t()) ::
          {:error, %{description: String.t(), message: String.t()}}
  def get_error_message(description) do
    {:error, %{message: "Calibration error", description: description}}
  end

  @spec get_error_description(calibration_session :: CalibrationSession.t() | map) ::
          String.t()
  def get_error_description(%CalibrationSession{} = calibration_session) do
    case calibration_session.status do
      :cartridge_status_error ->
        "Error `cartridgeStatus`"

      :submerged_in_water_error ->
        "Error `submergedInWater`"

      :cartridge_status_and_submerged_in_water_error ->
        "Error `submergedInWater` and `cartridgeStatus`"

      _ ->
        "Precheck 1 failure"
    end
  end

  def get_error_description(%{"precheck1" => :timeout}), do: "Precheck 1 timeout"
  def get_error_description(%{"precheck2" => :timeout}), do: "Precheck 2 timeout"
end
