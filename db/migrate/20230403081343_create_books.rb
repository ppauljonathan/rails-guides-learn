class CreateBooks < ActiveRecord::Migration::Current
  def change
    create_table :books do |t|
      t.string :name
      t.string :isbn
      t.decimal :price, precision: 5, scale: 2

      t.timestamps
    end
  end
end
