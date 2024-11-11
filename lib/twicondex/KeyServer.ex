defmodule Twicondex.KeyServer do
  @moduledoc """
   A GenServer responsible for caching and managing the Twitch OAuth access token.
  """
  use GenServer

  @doc """
  Starts the TokenServer with the provided configuration.

  The configuration should include `client_id` and `client_secret` required for OAuth.

  ## Parameters
  - `config`: A map containing `:client_id` and `:client_secret`.

  ## Returns
  - `{:ok, pid}` on success, where `pid` is the process ID of the GenServer.
  """
  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @impl true
  def init(config) do
    # Set initial state to include the configuration map
    {:ok, %{config: config, token_data: %{"access_token" => nil, "expires_at" => nil}}}
  end

  @doc """
  Retrieves the current OAuth token.

  This function checks if the token has expired and fetches a new one if necessary.

  ## Returns
  - `{:ok, access_token}` if the token is valid or has been successfully refreshed.
  - `{:error, reason}` if there is an issue with fetching the token.

  ## Example
      Twicondex.TokenServer.get_token()
  """
  def get_token do
    GenServer.call(__MODULE__, :get_token)
  end

  def get_client(), do: Application.get_env(:twicondex, :twitch_api_keys)[:client_id]

  @doc """
  Retrieves the current OAuth token.

  This function checks if the token has expired and fetches a new one if necessary.

  ## Returns
  - `"access_token"` if the token is valid or has been successfully refreshed.

  ## Example
      Twicondex.TokenServer.get_token!()
  """
  def get_token!() do
    {:ok, token} = get_token()
    token
  end

  ## Server Callbacks
  @doc """
  A callback function for handling requests to get the token.

  This function checks whether the token has expired and refreshes it if necessary.

  ## Parameters
  - `:get_token`: The request to retrieve the token.

  ## Returns
  - `{:ok, token}` if a valid token is available.
  - `{:error, reason}` if an error occurs.
  """
  @impl true
  def handle_call(:get_token, _from, state) do
    token_data = state[:token_data]

    case token_expired?(token_data["expires_at"]) do
      true -> fetch_and_store_token(state)
      false -> {:reply, {:ok, token_data["access_token"]}, state}
    end
  end

  ## Helper Functions

  # Check if the token has expired
  defp token_expired?(nil), do: true

  defp token_expired?(expires_at) do
    DateTime.compare(expires_at, DateTime.utc_now()) == :lt
  end

  # Fetch a new token and update the state
  defp fetch_and_store_token(state) do
    # Ensure config values are present
    %{client_id: client_id, client_secret: client_secret} = state.config

    case Twicondex.Client.fetch_access_token(client_id, client_secret) do
      {:ok, {access_token, expires_in}} ->
        expires_at = DateTime.add(DateTime.utc_now(), expires_in, :second)
        new_token_data = %{"access_token" => access_token, "expires_at" => expires_at}
        new_state = %{state | token_data: new_token_data}
        {:reply, {:ok, access_token}, new_state}

      {:error, error} ->
        {:reply, {:error, error}, state}
    end
  end
end
