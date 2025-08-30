defmodule AgenticDm.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :race, :string, null: false
      add :class, :string, null: false
      add :level, :integer, default: 1
      add :background, :string
      
      # D&D Stats
      add :strength, :integer, default: 10
      add :dexterity, :integer, default: 10
      add :constitution, :integer, default: 10
      add :intelligence, :integer, default: 10
      add :wisdom, :integer, default: 10
      add :charisma, :integer, default: 10
      
      # Health and Status
      add :current_hp, :integer
      add :max_hp, :integer
      add :temp_hp, :integer, default: 0
      add :armor_class, :integer, default: 10
      add :speed, :integer, default: 30
      add :proficiency_bonus, :integer, default: 2
      
      # Resources
      add :hit_dice, :string
      add :spell_slots, :text
      add :features, :text
      add :inventory, :text
      add :status_effects, :text
      
      # Personality and Background
      add :personality_traits, :text
      add :ideals, :text
      add :bonds, :text
      add :flaws, :text
      
      # Game State
      add :active, :boolean, default: true
      add :notes, :text

      timestamps()
    end

    create index(:characters, [:name])
    create index(:characters, [:active])
  end
end