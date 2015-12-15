defmodule TcpPing do
  use GenServer

  def start_link(listen_socket) do
    GenServer.start_link(__MODULE__, %{socket: listen_socket})
  end
  
  def init(state) do
    GenServer.cast(self, :accept)
    {:ok, state}
  end

  def handle_cast(:accept, state) do
    {:ok, accept_sock} = :gen_tcp.accept(state[:socket])
    TcpPing.Acceptor.start_client
    {:noreply, %{state | socket: accept_sock}}
  end

  def handle_info({:tcp_closed, sock}, state) do
    IO.inspect sock
    {:stop, :normal, state}
  end

  def handle_info({:tcp, sock, "ping\r\n"}, state) do
    IO.inspect sock
    IO.inspect state[:socket]
    :gen_tcp.send(state[:socket], "pong\r\n")
    {:noreply, state}
  end

  def handle_info({:tcp, _sock, msg}, state) do
    reply(state[:socket], msg)
    {:noreply, state}
  end

  defp reply(sock, msg) do
    :gen_tcp.send(sock, msg)
    :inet.setopts(sock, active: :once)
    :ok
  end
end
