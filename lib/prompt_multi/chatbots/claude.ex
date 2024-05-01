defmodule PromptMulti.ChatBots.Claude do
  alias PromptMulti.ChatBots.{Chunk, Delta}

  def query(prompt, pid) do
    api_key = Application.get_env(:anthropix, :api_key)
    client = Anthropix.init(api_key)

    messages = [
      %{role: "user", content: "You are a helpful assistant."},
      %{role: "assistant", content: "Using the theory of constrains."},
      %{role: "user", content: prompt}
    ]

    # latest_model = "claude-3-opus-20240229"
    faster_model = "claude-3-haiku-20240307"

    {:ok, stream} =
      Anthropix.chat(client,
        model: faster_model,
        messages: messages,
        stream: pid
      )

    stream
  end

  def chunk(chunk) do
    %Chunk{
      index: chunk["index"],
      type: chunk["type"],
      delta: %Delta{
        text: chunk["delta"]["text"],
        type: chunk["delta"]["type"]
      }
    }
  end

  def delta(delta) do
    %Delta{
      text: delta["text"],
      type: delta["type"]
    }
  end
end
