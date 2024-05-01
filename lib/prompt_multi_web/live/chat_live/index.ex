defmodule PromptMultiWeb.ChatLive.Index do
  use PromptMultiWeb, :live_view

  alias PromptMulti.ChatBots.Claude
  alias PromptMulti.ChatBots.OpenAI

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
      <div class="flex space-x-4">
        <div class="w-1/2 bg-gray-200 p-4">
          <h2 class="text-xl font-bold mb-2">+ Claude Response</h2>
          <p><%= @claude_response %></p>
        </div>
        <div class="w-1/2 bg-gray-300 p-4">
          <h2 class="text-xl font-bold mb-2">+ OpenAI Response</h2>
          <p><%= @open_ai_response %></p>
        </div>
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
    OpenAI.query(question, pid)

    {:noreply, assign(socket, question: question)}
  end

  @impl true
  def handle_info({_ref_id, {:data, message}}, socket) do
    case message["type"] do
      "content_block_delta" ->
        {:ok, message["delta"]["text"]}

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

  def handle_info({:gpt_response, decoded_data}, socket) do
    unless decoded_data["choices"] == [] do
      chunk = decoded_data["choices"] |> List.first() |> get_in(["delta", "content"])

      unless chunk == "" or is_nil(chunk) do
        {:noreply, assign(socket, open_ai_response: socket.assigns.open_ai_response <> chunk)}
      else
        {:noreply, socket}
      end
    else
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
