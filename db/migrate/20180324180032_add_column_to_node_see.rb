class AddColumnToNodeSee < ActiveRecord::Migration
  def change
    add_column :node, :token, :string
  end
end
