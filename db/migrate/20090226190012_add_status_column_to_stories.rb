class AddStatusColumnToStories < ActiveRecord::Migration
  def self.up
	  add_column :stories, :status, :string, :default => 'not_started'
  end

  def self.down
	  remove_column :stories, :status
  end
end
