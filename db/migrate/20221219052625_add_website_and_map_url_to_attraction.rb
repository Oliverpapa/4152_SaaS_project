class AddWebsiteAndMapUrlToAttraction < ActiveRecord::Migration
  def change
    add_column :attractions, :website, :string
    add_column :attractions, :map_url, :string
  end
end
