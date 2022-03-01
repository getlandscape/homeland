class AddActivityColumnsToTopics < ActiveRecord::Migration[7.0]
  def change
    add_column :topics, :starts_at, :datetime
    add_column :topics, :location, :string
    add_column :topics, :show_members, :boolean, default: true
    add_column :topics, :need_approve, :boolean, default: false
  end
end
