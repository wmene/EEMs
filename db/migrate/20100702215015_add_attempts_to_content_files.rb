class AddAttemptsToContentFiles < ActiveRecord::Migration
  def self.up
    add_column :content_files, :attempts, :integer
  end

  def self.down
    remove_column :content_files, :attempts
  end
end
