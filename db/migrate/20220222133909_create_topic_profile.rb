class CreateTopicProfile < ActiveRecord::Migration[7.0]
  def change
    create_table :topic_profile do |t|
      t.integer :topic_id, null: false
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :show_members, default: true
      t.boolean :need_approve, default: false
      t.integer :select_type, default: 0

      t.timestamps
    end
  end
end
