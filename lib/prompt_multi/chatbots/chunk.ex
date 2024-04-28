defmodule PromptMulti.ChatBots.Chunk do
  @moduledoc """
  A chunk is piece of tokenized text from a chatbot response.
    %PromptMulti.ChatBots.Chunk{
     index: 0,
     type: "content_block_delta",
     delta: %PromptMulti.ChatBots.Delta{text: " involving", type: "text_delta"}
  }
  """
  alias PromptMulti.ChatBots.Delta

  defstruct [:index, :type, delta: Delta]
end
