class CreateTopicOption < ActiveRecord::Migration[7.0]
  def change
    create_table :topic_options do |t|
      t.integer :topic_id, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
