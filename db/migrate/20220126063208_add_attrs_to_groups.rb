class AddAttrsToGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :groups, :show_members, :boolean, default: true
    add_column :groups, :need_approve, :boolean, default: false
    add_column :groups, :policy_agree, :boolean, default: false
  end
end
