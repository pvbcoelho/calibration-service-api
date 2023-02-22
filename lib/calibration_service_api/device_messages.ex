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

  def send("email_precheck1.false@test.com", "startPrecheck1"), do: %{"precheck1" => false}

  def send("email_timeout@teste.com", _command) do
    :timer.sleep(600)
    %{"precheck1" => false}
  end

  def send(_user_email, "startPrecheck1"), do: %{"precheck1" => true}
end
