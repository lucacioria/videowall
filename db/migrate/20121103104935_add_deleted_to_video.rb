class AddDeletedToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :deleted, :boolean
  end
end
