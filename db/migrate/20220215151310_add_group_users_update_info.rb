class AddGroupUsersUpdateInfo < ActiveRecord::Migration[7.0]
  def change
    add_column :group_users, :last_actor_id, :integer
    add_column :group_users, :last_action_type, :integer
    add_column :group_users, :deleted_at, :datetime

    add_index :group_users, :deleted_at
  end
end
