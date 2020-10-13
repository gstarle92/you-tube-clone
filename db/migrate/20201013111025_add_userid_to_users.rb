class AddUseridToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :userid, :integer
  end
end
