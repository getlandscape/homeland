class CreateUserTopic < ActiveRecord::Migration[7.0]
  def change
    create_table :user_topics do |t|
      t.integer :user_id, null: false
      t.integer :topic_id, null: false
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
