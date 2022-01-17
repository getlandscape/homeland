class CreateGroupUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :group_users do |t|
      t.integer :group_id, index: true, null: false
      t.integer :user_id, index: true, null: false
      t.integer :role
      t.integer :status

      t.timestamps
    end

    add_column :topics, :group_id, :integer
  end
end
