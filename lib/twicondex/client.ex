defmodule Twicondex.Client do
  @moduledoc """
  HTTP client module for interacting with the Twitch API.
  """

  alias Twicondex.TokenServer

  #@base_url "https://api.twitch.tv/helix"
  #@token_url "https://id.twitch.tv/oauth2/token"

  # mock
  @base_url "http://localhost:8080"
  @token_url "http://localhost:8080/auth/token"


  @doc """
  Fetches an access token using the client credentials.

  ## Parameters
    - `client_id`: The Twitch Client ID.
    - `client_secret`: The Twitch Client Secret.

  ## Returns
    - `{:ok, {access_token, expires_in}}` on success.
    - `{:error, reason}` on failure.
  """
  def fetch_access_token(client_id, client_secret) do
    body = %{
      client_id: client_id,
      client_secret: client_secret,
      grant_type: "client_credentials"
    }

    # Use Req to post to the token URL
    case Req.post(@token_url, params: body) do
      {:ok, %{status: 200, body: %{"access_token" => token, "expires_in" => expires_in}}} ->
        {:ok, {token, expires_in}}

      {:ok, %{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Makes a GET request to the specified Twitch API endpoint.

  ## Parameters
    - `endpoint`: API endpoint (e.g., "/users").
    - `access_token`: Access token for authorization.

  ## Returns
    - `{:ok, response_body}` on success.
    - `{:error, reason}` on failure.
  """
  def get(endpoint, access_token) do
    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Client-Id", TokenServer.get_client}
    ]

    case Req.get(@base_url <> endpoint, headers: headers) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
