defmodule CalibrationServiceApi.CalibrationSession do
  @moduledoc """
  A struct representing an ongoing calibration session, used to identify who the session
  belongs to, what step the session is on, and any other information relevant to working
  with the session.
  """

  @type t() :: %__MODULE__{
          user_device: String.t(),
          session: Atom.t(),
          status:
            :on_going
            | :finished
            | :error
            | :timeout
            | :cartridge_status_error
            | :submerged_in_water_error
            | :cartridge_status_and_submerged_in_water_error
        }

  @derive [Jason.Encoder]
  defstruct [
    :user_device,
    :session,
    :status
  ]
end
