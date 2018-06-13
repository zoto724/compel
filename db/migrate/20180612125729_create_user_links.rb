class CreateUserLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :user_links do |t|
      t.string :link
      t.integer :user_id

      t.timestamps
    end
    add_index :user_links, :user_id
  end
end
