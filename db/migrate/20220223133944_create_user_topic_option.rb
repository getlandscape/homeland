class CreateUserTopicOption < ActiveRecord::Migration[7.0]
  def change
    create_table :user_topic_options do |t|
      t.integer :user_id, null: false
      t.integer :topic_option_id, null: false
      t.integer :topic_id, null: false

      t.timestamps
    end
  end
end
