defmodule CalibrationServiceApiWeb.Router do
  use CalibrationServiceApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CalibrationServiceApiWeb do
    pipe_through :api
  end
end
