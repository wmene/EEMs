class AddUserDisplayNameToContentFiles < ActiveRecord::Migration
  def self.up
    add_column :content_files, :user_display_name, :string
  end

  def self.down
    remove_column :content_files, :user_display_name
  end
end
