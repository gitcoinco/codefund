defmodule Redis.Connection do
  use GenServer

  @spec start_link(nil) :: :ignore | {:error, any} | {:ok, pid()}
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: :"#{__MODULE__}_#{UUID.uuid4()}")
  end

  @spec init(:ok) :: {:ok, [redis_connection: pid()]}
  def init(:ok) do
    {:ok, redis_connection} = open_connection()

    {:ok, [redis_connection: redis_connection]}
  end

  def handle_call({:commands, [list], ref}, _from, [redis_connection: redis_connection] = state) do
    {:ok, result} = Redix.command(redis_connection, list)

    {:reply, {ref, {:ok, [result]}}, state}
  end

  defp open_connection() do
    {:ok, _redis_connection} =
      Redix.start_link(
        host: Application.get_env(:redix, :host),
        port: Application.get_env(:redix, :port),
        database: Application.get_env(:redix, :database),
        password: Application.get_env(:redix, :password)
      )
  end
end
