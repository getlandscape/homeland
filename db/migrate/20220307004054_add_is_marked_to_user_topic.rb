class AddIsMarkedToUserTopic < ActiveRecord::Migration[7.0]
  def change
    add_column :user_topics, :is_marked, :boolean, default: false
  end
end
