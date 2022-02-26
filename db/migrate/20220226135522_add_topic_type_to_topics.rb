class AddTopicTypeToTopics < ActiveRecord::Migration[7.0]
  def change
    add_column :topics, :topic_type, :integer, default: 0
  end
end
