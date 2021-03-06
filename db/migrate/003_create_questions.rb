# db/migrate/003_create_questions.rb
class CreateQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :questions do |t|
      t.belongs_to :scenario, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :order
      t.string :text
      t.string :description

      t.timestamps
    end

    # ensure that two questions in the same scenario can't have the same position in the order
    add_index :questions, [:scenario_id, :order], unique: true
  end
end
