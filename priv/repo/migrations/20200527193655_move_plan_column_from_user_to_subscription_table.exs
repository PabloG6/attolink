defmodule AttoLink.Repo.Migrations.MovePlanColumnFromUserToSubscriptionTable do
  use Ecto.Migration
  alias AttoLink.Repo
  import Ecto.Query
  alias AttoLink.{Payments, Payments.Subscription}

  def up do
    alter table(:user) do
      remove :plan
    end

    alter table(:subscription) do
      remove :plan_name
    end

    from(s in Subscription, update: [set: [nickname: fragment("lower(?)", s.nickname)]])
    |> Repo.update_all([])

    execute """
      alter table subscription alter column nickname type varchar(255) USING nickname::plan
    """
  end

  def down do
    alter table(:user) do
      add :plan, Plan.type(), default: "free"
    end

    alter table(:subscription) do
      modify :nickname, :string, default: "free"
    end
  end
end
