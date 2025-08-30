defmodule AgenticDm.Schemas.Character do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "characters" do
    field :name, :string
    field :race, :string
    field :class, :string
    field :level, :integer, default: 1
    field :background, :string
    
    # D&D Stats
    field :strength, :integer, default: 10
    field :dexterity, :integer, default: 10
    field :constitution, :integer, default: 10
    field :intelligence, :integer, default: 10
    field :wisdom, :integer, default: 10
    field :charisma, :integer, default: 10
    
    # Health and Status
    field :current_hp, :integer
    field :max_hp, :integer
    field :temp_hp, :integer, default: 0
    field :armor_class, :integer, default: 10
    field :speed, :integer, default: 30
    field :proficiency_bonus, :integer, default: 2
    
    # Resources
    field :hit_dice, :string
    field :spell_slots, :map, default: %{}
    field :features, {:array, :string}, default: []
    field :inventory, {:array, :map}, default: []
    field :status_effects, {:array, :map}, default: []
    
    # Personality and Background
    field :personality_traits, :string
    field :ideals, :string
    field :bonds, :string
    field :flaws, :string
    
    # Game State
    field :active, :boolean, default: true
    field :notes, :string
    
    timestamps()
  end

  @doc false
  def changeset(character, attrs) do
    character
    |> cast(attrs, [
      :name, :race, :class, :level, :background,
      :strength, :dexterity, :constitution, :intelligence, :wisdom, :charisma,
      :current_hp, :max_hp, :temp_hp, :armor_class, :speed, :proficiency_bonus,
      :hit_dice, :spell_slots, :features, :inventory, :status_effects,
      :personality_traits, :ideals, :bonds, :flaws, :active, :notes
    ])
    |> validate_required([:name, :race, :class, :level])
    |> validate_number(:level, greater_than: 0, less_than_or_equal_to: 20)
    |> validate_number(:strength, greater_than: 0, less_than_or_equal_to: 30)
    |> validate_number(:dexterity, greater_than: 0, less_than_or_equal_to: 30)
    |> validate_number(:constitution, greater_than: 0, less_than_or_equal_to: 30)
    |> validate_number(:intelligence, greater_than: 0, less_than_or_equal_to: 30)
    |> validate_number(:wisdom, greater_than: 0, less_than_or_equal_to: 30)
    |> validate_number(:charisma, greater_than: 0, less_than_or_equal_to: 30)
  end
  
  def ability_modifier(ability_score) do
    trunc((ability_score - 10) / 2)
  end
  
  def calculate_modifiers(character) do
    %{
      str_mod: ability_modifier(character.strength),
      dex_mod: ability_modifier(character.dexterity),
      con_mod: ability_modifier(character.constitution),
      int_mod: ability_modifier(character.intelligence),
      wis_mod: ability_modifier(character.wisdom),
      cha_mod: ability_modifier(character.charisma)
    }
  end
end