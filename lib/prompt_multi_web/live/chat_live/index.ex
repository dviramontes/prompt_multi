defmodule PromptMultiWeb.ChatLive.Index do
  import PromptMultiWeb.CoreComponents
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <div class="flex flex-1 flex-col">
      <h1>Chat</h1>
      <div class="chat-window">
        <%= for message <- @messages do %>
          <p><%= message %></p>
        <% end %>
      </div>
      <.simple_form for={%{}} phx-submit="send-message">
        <.input name="message" label="Message" placeholder="How can I help today?" value={nil} />
        <:actions>
          <.button>Send</.button>
        </:actions>
      </.simple_form>
    </div>

    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, messages: [])}
  end

  def handle_event("send-message", %{"message" => message}, socket) do
    {:noreply, assign(socket, messages: [message | socket.assigns.messages])}
  end

end
