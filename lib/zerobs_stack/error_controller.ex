defmodule ZerobsStack.ErrorController do
  import Plug.Conn

  def call(conn, {:error, :rate_limit_reached}) do
    conn
    |> send_resp(503, "rate limit reached")
  end

  def call(conn, {:error, :load_shedding}) do
    conn
    |> send_resp(503, "load shedding activated")
  end
end
