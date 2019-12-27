defmodule ZerobsStack.AdminPanel do
  use Plug.Router

  plug(:match)
  plug(:dispatch)
  # TODO: read those from  the host app, generate them with install task
  plug(Plug.Session,
    store: :cookie,
    key: "_zerobs_stack_admin",
    signing_salt: "XaiGeghien8uPheish4OopeiQua5ouwa",
    encrpytion_salt: "zah9eefiphahk0teix6Aa8chah1cae8r"
  )

  forward("/feature-flags", to: FunWithFlags.UI.Router, init_opts: [namespace: "feature-flags"])
  forward("/metrics", to: ZerobsStack.MetricsPlug)
  forward("/kubernetes/ready", to: ZerobsStack.ReadinessPlug)

  match _ do
    send_resp(conn, 404, "oops")
  end
end
