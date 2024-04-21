defmodule PromptMulti.Repo do
  use Ecto.Repo,
    otp_app: :prompt_multi,
    adapter: Ecto.Adapters.SQLite3
end
