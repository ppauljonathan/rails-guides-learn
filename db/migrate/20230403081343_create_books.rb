class CreateBooks < ActiveRecord::Migration::Current
  def change
    create_table :books do |t|
      t.string :name

      t.timestamps
    end
  end
end
