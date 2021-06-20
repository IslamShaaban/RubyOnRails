class CreateTags < ActiveRecord::Migration[6.1]
  def change
    create_table :tags do |t|
      t.string     :tags
      t.references :post, index: true
      t.timestamps
    end
  end
end