defmodule BuzzcmsWeb.Router do
  use BuzzcmsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BuzzcmsWeb do
    pipe_through :api
  end
end
