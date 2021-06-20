class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.text :body
      t.references :post, index: true
      t.references :user, index: true
      t.timestamps
    end
  end
end