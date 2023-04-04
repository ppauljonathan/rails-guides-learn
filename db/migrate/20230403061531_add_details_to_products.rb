class AddDetailsToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :price, :decimal, precision: 5, scale: 3
    add_reference :products, :supplier, polymorphic: true, null: false
  end
end
