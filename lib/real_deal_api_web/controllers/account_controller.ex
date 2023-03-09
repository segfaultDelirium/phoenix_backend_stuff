defmodule RealDealApiWeb.AccountController do
  use RealDealApiWeb, :controller

  # alias RealDealApi.Accounts
  # alias RealDealApi.Accounts.Account
  # alias RealDealApi.Users.User
  alias RealDealApi.{Accounts, Accounts.Account, Users, Users.User}
  alias RealDealApiWeb.Auth.Guardian
  alias RealDealApiWeb.Auth.ErrorResponse
  plug :is_authorized_account when action in [:update, :delete]

  action_fallback RealDealApiWeb.FallbackController

  defp is_authorized_account(conn, _options) do
    %{params: %{"account" => params}} = conn
    account = Accounts.get_account!(params["id"])

    if conn.assigns.account.id == account.id do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, :index, accounts: accounts)
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.create_account(account_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(account),
         {:ok, %User{} = _user} <- Users.create_user(account, account_params) do
      conn
      |> put_status(:created)
      # |> put_resp_header("location", ~p"/api/accounts/#{account}")
      # |> render(:show, account: account)
      |> render(:account_token, account: account, token: token)
    end
  end

  def sign_in(conn, %{"email" => email, "hashed_password" => hashed_password}) do
    case Guardian.authenticate(email, hashed_password) do
      {:ok, account, token} ->
        conn
        |> Plug.Conn.put_session(:account_id, account.id)
        |> put_status(:ok)
        |> render(:account_token, account: account, token: token)

      {:error, :unauthorized} ->
        raise ErrorResponse.Unauthorized, message: "email or password incorrect"
    end
  end

  def sign_in(_conn, %{}) do
    raise ErrorResponse.Unauthorized,
      message: """
      Invalid input json format.
      Example of correct format:
      {
      "email": "first_account8@test.com",
      "hashed_password": "my_hashed_password"
      }
      """
  end

  def show(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    render(conn, :show, account: account)
  end

  def show(conn, %{}) do
    account = conn.assigns[:account]
    render(conn, :show, account: account)
  end

  # def update(conn, %{"id" => id, "account" => account_params}) do
  def update(conn, %{"account" => account_params}) do
    account = Accounts.get_account!(account_params["id"])

    with {:ok, %Account{} = account} <- Accounts.update_account(account, account_params) do
      render(conn, :show, account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end
end
