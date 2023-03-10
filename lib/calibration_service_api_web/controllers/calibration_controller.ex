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

  def start_precheck_2(conn, %{"user_email" => user_email}) do
    with {:ok, response} <- ElixirInterviewStarter.start_precheck_2(user_email) do
      conn
      |> put_status(:ok)
      |> json(response)
    end
  end

  def get_current_session(conn, %{"user_email" => user_email} = _params) do
    with {:ok, response} <- ElixirInterviewStarter.get_current_session(user_email) do
      conn
      |> put_status(:ok)
      |> json(response)
    end
  end
end
