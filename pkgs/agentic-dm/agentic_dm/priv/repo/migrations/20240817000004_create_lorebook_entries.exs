defmodule AgenticDm.Repo.Migrations.CreateLorebookEntries do
  use Ecto.Migration

  def change do
    create table(:lorebook_entries, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :content, :text, null: false
      add :keywords, :text
      add :priority, :integer, default: 1
      add :category, :string
      add :campaign_name, :string, null: false
      
      # Trigger Settings
      add :trigger_conditions, :text
      add :insertion_order, :integer, default: 100
      add :max_triggers_per_session, :integer, default: 5
      add :current_session_triggers, :integer, default: 0
      
      # Content Management
      add :token_budget, :integer, default: 500
      add :insertion_position, :string, default: "context"
      add :active, :boolean, default: true
      add :auto_trigger, :boolean, default: true
      
      # Metadata
      add :created_by, :string
      add :last_triggered, :utc_datetime
      add :trigger_count, :integer, default: 0
      add :notes, :text

      timestamps()
    end

    create index(:lorebook_entries, [:campaign_name])
    create index(:lorebook_entries, [:category])
    create index(:lorebook_entries, [:active])
    create index(:lorebook_entries, [:priority])
  end
end