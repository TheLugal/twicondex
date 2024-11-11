defmodule Twicondex.Conduit do
  use GenServer

  # Public API
  def create_conduit(events, config) do
    GenServer.call(__MODULE__, {:create, events, config})
  end

  def delete_conduit(conduit_id) do
    GenServer.call(__MODULE__, {:delete, conduit_id})
  end

  # GenServer Callbacks
  def init(state) do
    {:ok, state}
  end

  def handle_call({:create, events, config}, _from, state) do
    # Logic to create the conduit (e.g., create a connection, register events)
    # You would likely need to interact with Twitch API here to initiate the conduit
    conduit_id = create_conduit_for_events(events, config)
    {:reply, {:ok, conduit_id}, state}
  end

  def handle_call({:delete, conduit_id}, _from, state) do
    # Logic to delete the conduit (e.g., unsubscribe from events, close the connection)
    delete_conduit_by_id(conduit_id)
    {:reply, :ok, state}
  end

  # Private helper functions for creating/deleting conduits
  defp create_conduit_for_events(events, config) do
    # Handle the creation logic here (e.g., make HTTP requests to Twitch API)
    # Return the conduit ID for reference
  end

  defp delete_conduit_by_id(conduit_id) do
    # Handle the deletion logic here (e.g., clean up, close WebSocket, unsubscribe from events)
  end
end
