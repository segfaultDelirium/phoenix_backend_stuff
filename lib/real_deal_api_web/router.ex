defmodule RealDealApiWeb.Router do
  use RealDealApiWeb, :router
  use Plug.ErrorHandler

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{message: message}}) do
    conn |> json(%{errors: message}) |> halt()
  end

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{reason: %{message: message}}) do
    conn |> json(%{errors: message}) |> halt()
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug RealDealApiWeb.Auth.Pipeline
  end

  scope "/api", RealDealApiWeb do
    pipe_through :api
    get "/", DefaultController, :index
    get "/weather", WeatherController, :get_sample_weather
    post "/accounts/create", AccountController, :create
    post "/accounts/sign_in", AccountController, :sign_in
    get "/accounts", AccountController, :index
  end

  scope "/api", RealDealApiWeb do
    pipe_through [:api, :auth]
    get "/accounts/by_id/:id", AccountController, :show
  end

end
