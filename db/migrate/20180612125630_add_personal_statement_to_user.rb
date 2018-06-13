class AddPersonalStatementToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :personal_statement, :text
  end
end
