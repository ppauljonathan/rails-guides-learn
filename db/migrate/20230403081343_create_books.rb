class CreateBooks < ActiveRecord::Migration::Current
  def change
    create_table :books do |t|
      t.string :name
      t.belongs_to :library, foreign_key: true

      t.timestamps
    end
  end
end
