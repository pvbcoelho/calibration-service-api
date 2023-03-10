defmodule CalibrationServiceApiWeb.Router do
  use CalibrationServiceApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CalibrationServiceApiWeb do
    pipe_through :api
    post("/start", CalibrationController, :start)
    post("/start_precheck_2", CalibrationController, :start_precheck_2)
    get("/get_current_session/:user_email", CalibrationController, :get_current_session)
  end
end
