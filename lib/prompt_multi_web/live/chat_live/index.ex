defmodule PromptMultiWeb.ChatLive.Index do
  use PromptMultiWeb, :live_view

  alias PromptMulti.ChatBots.Claude

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-1 flex-col">
      <h1>Chat</h1>
      <pre><%= inspect(self()) %></pre>
      <.simple_form for={%{}} phx-submit="query">
        <.input name="question" label="Message" placeholder="How can I help today?" value={nil} />
        <:actions>
          <.button>Send</.button>
        </:actions>
      </.simple_form>
      <div :if={@question} class="flex flex-col">
        <h2>> Question</h2>
        <p>>>><%= @question %></p>
      </div>
      <div :if={@claude_response} class="flex flex-col">
        <h2>+ Claude Response</h2>
        <p><%= @claude_response %></p>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       messages: [],
       content: nil,
       question: nil,
       claude_response: "",
       open_ai_response: ""
     )}
  end

  @impl true
  def handle_event("query", %{"question" => question}, socket) do
    pid = self()

    _stream = Claude.query(question, pid)

    {:noreply, assign(socket, question: question)}
  end

  @impl true
  def handle_info({_ref_id, {:data, message}}, socket) do
    case message["type"] do
      "message_start" ->
        IO.puts("message_start")

      "content_block_start" ->
        IO.puts("content_block_start")

      "content_block_delta" ->
        IO.puts("content_block_start")
        {:ok, message["delta"]["text"]}

      "message_stop" ->
        IO.puts("message_stop")

      message_type ->
        IO.puts("#message: #{message_type}, not handled")
    end
    |> case do
      {:ok, chunk} ->
        {:noreply, assign(socket, claude_response: socket.assigns.claude_response <> chunk)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_info({_ref_id, {:ok, %{"content" => [content]}}}, socket) do
    IO.puts("CONTENT DONE")
    {:noreply, assign(socket, content: content)}
  end

  def handle_info({:DOWN, _ref_id, _, _, _}, socket) do
    IO.puts("DOWN")
    {:noreply, socket}
  end
end
