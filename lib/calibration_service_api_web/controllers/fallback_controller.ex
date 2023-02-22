defmodule CalibrationServiceApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use CalibrationServiceApiWeb, :controller

  # This clause is an example of how to handle resources that cannot be found.

  def call(conn, {:error, %{message: "User not found"} = message}) do
    conn
    |> put_status(:not_found)
    |> json(%{"error" => message})
  end

  def call(conn, {:error, message}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{"error" => message})
  end
end
