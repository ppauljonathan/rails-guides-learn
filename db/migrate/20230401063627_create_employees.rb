class CreateEmployees < ActiveRecord::Migration[7.0]
  def change
    create_table :employees do |t|
      t.string :name
      t.string :designation

      t.timestamps
    end

    say 'Created Employees Table'

    suppress_messages { add_index :employees, :name }
    say 'add_an_index', true

    say_with_time 'waiting' do
      sleep 2
      100
    end
  end
end
