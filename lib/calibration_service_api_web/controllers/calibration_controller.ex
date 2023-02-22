defmodule CalibrationServiceApiWeb.CalibrationController do
  use CalibrationServiceApiWeb, :controller

  alias CalibrationServiceApi.ElixirInterviewStarter

  action_fallback CalibrationServiceApiWeb.FallbackController

  def start(conn, %{"user_email" => user_email}) do
    with {:ok, response} <- ElixirInterviewStarter.start(user_email) do
      conn
      |> put_status(:ok)
      |> json(response)
    end
  end
end
