defmodule Todo.Router do
  use Plug.Router

  alias Todo.Server

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "ok")
  end

  get "/list" do
    state = Server.list()
    send_resp(conn, 200, Poison.encode!(%{data: state, success: true}))
  end

  get "/add/:name" do
    %{params: %{"name" => task_name}} = fetch_query_params(conn)
    state = Server.add(task_name)
    send_resp(conn, 200, Poison.encode!(state))
  end

  get "/remove/:id" do
    %{params: %{"id" => id}} = fetch_query_params(conn)
    state = Server.remove(id)
    send_resp(conn, 200, Poison.encode!(state))
  end

  get "/toggle/:id" do
    %{params: %{"id" => id}} = fetch_query_params(conn)
    state = Server.toggle(id)
    send_resp(conn, 200, Poison.encode!(%{data: state, sucess: true}))
  end

  match(_, do: send_resp(conn, 404, "This is not the page you are looking for"))
end
