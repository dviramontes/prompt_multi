defmodule PromptMulti.ChatBots.OpenAI do
  @chat_completions_url "https://api.openai.com/v1/chat/completions"

  def query(prompt, pid) do
    fun = fn request, finch_request, finch_name, finch_options ->
      fun = fn
        {:status, status}, response ->
          %{response | status: status}

        {:headers, headers}, response ->
          %{response | headers: headers}

        {:data, data}, response ->
          body =
            data
            |> String.split("data: ")
            |> Enum.map(fn str ->
              str
              |> String.trim()
              |> decode_body(pid)
            end)
            |> Enum.filter(fn d -> d != :ok end)

          old_body = if response.body == "", do: [], else: response.body

          %{response | body: old_body ++ body}
      end

      case Finch.stream(finch_request, finch_name, Req.Response.new(), fun, finch_options) do
        {:ok, response} -> {request, response}
        {:error, exception} -> {request, exception}
      end
    end

    Req.post!(@chat_completions_url,
      json: %{
        model: "gpt-3.5-turbo-0125",
#        model: "gpt-3.5-turbo-0301",
#        model: "gpt-4-turbo-2024-04-09",
        messages: [%{role: "user", content: prompt}],
        stream: true
      },
      auth: {:bearer, api_key()},
      finch_request: fun
    )
  end

  ## PRIVATE FUNCTIONS

  defp api_key do
    Application.get_env(:openai, :api_key)
  end

  defp decode_body("", _), do: :ok
  defp decode_body("[DONE]", _), do: :ok

  defp decode_body(json, live_view_pid) do
    case Jason.decode(json) do
      {:ok, decoded_data} ->
        send(live_view_pid, {:gpt_response, decoded_data})
        :ok

      {:error, _} ->
        :ok
    end
  end
end
