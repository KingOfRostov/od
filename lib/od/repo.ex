defmodule Od.Repo do
  use Ecto.Repo,
    otp_app: :od,
    adapter: Ecto.Adapters.Postgres
end
