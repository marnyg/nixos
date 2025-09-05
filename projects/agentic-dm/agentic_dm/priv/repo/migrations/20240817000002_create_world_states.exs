defmodule AgenticDm.Repo.Migrations.CreateWorldStates do
  use Ecto.Migration

  def change do
    create table(:world_states, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :campaign_name, :string, null: false
      
      # World Environment
      add :current_location, :string
      add :time_of_day, :string, default: "midday"
      add :weather, :string, default: "clear"
      add :season, :string, default: "spring"
      add :date, :string
      
      # World Data
      add :locations, :text
      add :npcs, :text
      add :events, :text
      add :story_flags, :text
      add :quest_log, :text
      
      # State Management
      add :active, :boolean, default: true
      add :version, :integer, default: 1

      timestamps()
    end

    create index(:world_states, [:campaign_name])
    create index(:world_states, [:active])
    create index(:world_states, [:name])
  end
end