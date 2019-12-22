defmodule ZerobsStack.AdminPanel do
  use Plug.Router
  plug(:match)
  plug(:dispatch)
  forward("/feature-flags", to: FunWithFlags.UI.Router, init_opts: [namespace: "feature-flags"])
end
