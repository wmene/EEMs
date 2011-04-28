class CreateContentFiles < ActiveRecord::Migration
  def self.up
    create_table :content_files do |t|
      t.string :url
      t.integer :percent_done
      t.string :path

      t.timestamps
    end
  end

  def self.down
    drop_table :content_files
  end
end
