class CreateUserTopicOption < ActiveRecord::Migration[7.0]
  def change
    create_table :user_topic_options do |t|

      t.timestamps
    end
  end
end
