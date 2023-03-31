class TestMigration < ActiveRecord::Migration[7.0]
  def change
    create_table :cars do |t|
      t.string :name
    end

    # ENGINE OPTIONS
    # create_table :cars, options: 'ENGINE=BLACKHOLE' do |t|
    #   t.string :name, null: false
    # end

    # INDEXING OPTIONS
    create_table :people do |t|
      t.string :name, index: true
      t.string :email, index: {
        unique: true,
        name: 'unique_emails',
        comment: 'email must be unique and is indexed with unique indexing' # only in mysql and postgresql
      }
    end

    # CAN ALSO CREATE WITHOUT BLOCK
    # create_table :students
    # add_column :students, :name, :string, index: {...}
  end
end
