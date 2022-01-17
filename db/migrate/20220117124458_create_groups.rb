class CreateGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :groups do |t|
      t.string :title, null: false
      t.string :description
      t.string :avatar
      t.integer :topics_count, default: 0, null: false
      t.integer :replies_count, default: 0, null: false
      t.integer :group_type, default: 0, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
