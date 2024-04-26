class AddPhaseToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :phase, :integer
  end
end
