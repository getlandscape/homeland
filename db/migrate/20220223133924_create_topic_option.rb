class CreateTopicOption < ActiveRecord::Migration[7.0]
  def change
    create_table :topic_options do |t|

      t.timestamps
    end
  end
end
