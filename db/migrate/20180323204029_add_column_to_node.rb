class AddColumnToNode < ActiveRecord::Migration
  def change
    add_column :node, :string, :token
  end
end
