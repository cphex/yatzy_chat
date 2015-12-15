defmodule TcpPing.Acceptor do
  use Supervisor

  def start_client do
    Supervisor.start_child(__MODULE__, [])
  end

  # Callbacks

  def start_link(port) do
    Supervisor.start_link(__MODULE__, port, [name: __MODULE__])
  end

  def init(port) do
    {:ok, l_sock} = :gen_tcp.listen(port,
                                    [:binary,
                                    active: :once])
    workers = [
      worker(TcpPing, [l_sock])
    ]

    supervise(workers, [strategy: :simple_one_for_one])
  end
end
