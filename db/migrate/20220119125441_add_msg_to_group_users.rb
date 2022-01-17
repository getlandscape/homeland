class AddMsgToGroupUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :group_users, :msg, :text
  end
end
