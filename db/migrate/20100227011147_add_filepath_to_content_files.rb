class AddFilepathToContentFiles < ActiveRecord::Migration
  def self.up
    add_column :content_files, :filepath, :string
  end

  def self.down
    remove_column :content_files, :filepath
  end
end
