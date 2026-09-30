class CreateUserProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :user_profiles do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.text :bio
      t.string :website

      t.timestamps
    end
  end
end
