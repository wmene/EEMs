class AddPartPidToContentFiles < ActiveRecord::Migration
  def self.up
    add_column :content_files, :part_pid, :string
  end

  def self.down
    remove_column :content_files, :part_pid
  end
end
