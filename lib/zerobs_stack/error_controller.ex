defmodule ZerobsStack.ErrorController do
  import Plug.Conn

  def call(conn, {:error, :rate_limit_reached}) do
    conn
    |> send_resp(429, "Your request has been ratelimited.")
  end

  def call(conn, {:error, :load_shedding}) do
    conn
    |> send_resp(503, "load shedding activated")
  end
end
