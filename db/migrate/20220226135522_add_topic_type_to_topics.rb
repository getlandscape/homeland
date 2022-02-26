class AddTopicTypeToTopics < ActiveRecord::Migration[7.0]
  def change
    add_column :topics, :topic_type, :integer, default: 0
    add_column :topics, :ends_at, :datetime
    add_column :topics, :select_type, :integer, default: 0
  end
end
