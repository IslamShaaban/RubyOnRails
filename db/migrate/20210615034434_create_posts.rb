class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :body
      t.references :user
      t.timestamps
    end
    add_foreign_key :posts, :users
  end
end