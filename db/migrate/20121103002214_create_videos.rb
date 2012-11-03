class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.text :video_url, :null => false
      t.string :video_type, :null => false
      t.datetime :action_date, :null  => true
      t.boolean :hidden, :null => false, :default => false
      t.boolean :starred, :null => false, :default => false

      t.timestamps
    end
  end
end
