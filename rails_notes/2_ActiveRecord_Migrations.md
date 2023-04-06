# Migrations - alter db schema over time in a consistent way

```ruby
  class CreateProducts < ActiveRecord::Migration[7.0]
    def change
      create_table :products do |t|
        t.string :name
        t.text :description

        t.timestamps
      end
    end
  end
```

  - id -> PK, created automatically
  - name -> string
  - description -> text
  - timestamps -> created_at, updated_at
  
  when `$ rails db:migrate` is run, table is made and db changes are made, `$ rails db:rollback` rolls back the current migration
  
  migrations are wrapped with transactions in dbs that support this
  
  if a migration cannot be rolled back we define it through the following methods
  
  1. using reversible
  
```ruby
class ChangeProductsPrice < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      change_table :products do |t|
        dir.up   { t.change :price, :string }
        dir.down { t.change :price, :integer }
      end
    end
  end
end
```

  2. using up and down methods
```ruby
  class ChangeProductsPrice < ActiveRecord::Migration[7.0]
    def up
      change_table :products do |t|
        t.change :price, :string
      end
    end

    def down
      change_table :products do |t|
        t.change :price, :integer
      end
    end
  end
```


# Creating migrations

we can create migrations using rails generator, the format for a migration is `YYYYMMDDHHMMSS_create_products.rb`

we can create it by running:
`$ (bin/)rails g(enerate) migration [MigrationName]`

ex: `$ rails g migration AddPartNumberToProducts`
```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.0]
  def change
  end
end
```

if format is AddXXToTableName and we follow with some c1:d1 c2:d2 ...
the migration will be generated with
```ruby
  add_column :table_name, :c1, :d1
  add_column :table_name, :c2, :d2
  .
  .
  .
```
inside the change method

`$ bin/rails generate migration AddPartNumberToProducts part_number:string`

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :part_number, :string
  end
end
```

we can also add other propertes to the column 
`$ bin/rails generate migration AddPartNumberToProducts part_number:string:index`

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```

removing a column
$ bin/rails generate migration RemovePartNumberFromProducts part_number:string
class RemovePartNumberFromProducts < ActiveRecord::Migration[7.0]
  def change
    remove_column :products, :part_number, :string
  end
end

creating a table, we use
$ rails g migration CreateTableName c1:d1 c2:d2 ...
class CreateTableName < ActiveRecord::Migration[7.0]
  def change
    create_table do |t|
      t.d1 :c1,
      t.d2 :c2,
      .
      .
      .
    end
  end
end

all migrations generated can be modified

references can be added to a table like so
$ rails g migration AddTab1RefToTab2 tab1:references
class AddTab1RefToTab2 < ActiveRecord::Migration[7.0]
  def change
    add_reference :tab2, :tab1, foreign_key: true
  end
end

# creates foreign key tab1_id

we can also make join tables which are different from joins, they represent the associations between customer and product
$ bin/rails generate migration CreateJoinTableCustomerProduct customer product

class CreateJoinTableCustomerProduct < ActiveRecord::Migration[7.0]
  def change
    create_join_table :customers, :products do |t|
      # t.index [:customer_id, :product_id]
      # t.index [:product_id, :customer_id]
      # we can create an index like so
    end
  end
end

the join table is created in lexical order of the first 2 arguments to create_join_table
ex: create_join_table :people, :cars #=> creates a table called :cars_people

# model generators
$ bin/rails generate model Product name:string description:text
makes a migration like so:
class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end

we can also pass modifiers to the migration definintion
$ bin/rails generate migration AddDetailsToProducts 'price:decimal{5,2}' supplier:references{polymorphic}
which gives:
class AddDetailsToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :price, :decimal, precision: 5, scale: 2
    add_reference :products, :supplier, polymorphic: true
  end
end

# wrinting migrations

# creating a table
create_table :products do |t|
  t.string :name
end

create_table :products, options: 'SQL STRING' do |t|
  t.string :name, null: [true/false], index: true, index: { name: '...', unique: true }
end

# join table
create_join_table :products, :categories #=> creates table named categories_products

we can also customize the table name
create_join_table :products, :categories, table_name: :categorization

the columns have been set to have no null values by default

create_join_table :products, :categories, column_options: { null: true }


# column modifiers

add_column(:tab_name, :col_name, type: {
  :string, :text, :integer, :float, :decimal, :timestamp, :time, :date, :binary, :boolean
}, opts: {
  default: DEFAULT_VALUE,
  limit:
  null: [t/f]
})

add_foreign_key :from_table, :to_table, opts: {}

add_index :tab_name, :col_name, opts: {}

add_reference :table, :ref
# creates column named ref_id in :table, by default index is true on this column
add_reference :table, :ref, index: false

# adding a polymorphic reference created 2 columns ref_type, ref_id
add_reference :table, :ref, polymorphic: true
remove_reference :products, :user, foreign_key: true, index: false

# custom commands to pass to sql engine
Product.connection.execute("UPDATE products SET price = 'free' WHERE 1=1") # where product can be substituted with table name

The change method is the primary way of writing migrations. It works for the majority of cases in which Active Record knows how to reverse a migration's actions automatically. Below are some of the actions that change supports:

    add_column
    add_foreign_key
    add_index
    add_reference
    add_timestamps
    change_column_comment (must supply a :from and :to option)
    change_column_default (must supply a :from and :to option)
    change_column_null
    change_table_comment (must supply a :from and :to option)
    create_join_table
    create_table
    disable_extension
    drop_join_table
    drop_table (must supply a block)
    enable_extension
    remove_column (must supply a type)
    remove_foreign_key (must supply a second table)
    remove_index
    remove_reference
    remove_timestamps
    rename_column
    rename_index
    rename_table

change_table is also reversible, as long as the block does not call change, change_default or remove.

remove_column is reversible if you supply the column type as the third argument. Provide the original column options too, otherwise Rails can't recreate the column exactly when rolling back:
    
    remove_column :posts, :slug, :string, null: false, default: ''

If you're going to need to use any other methods, you should use reversible or write the up and down methods instead of using the change method.

Complex migrations may require processing that Active Record doesn't know how to reverse. You can use reversible to specify what to do when running a migration and what else to do when reverting it. For example:

class ExampleMigration < ActiveRecord::Migration[7.0]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end

    reversible do |dir|
      dir.up do
        # add a CHECK constraint
        execute <<-SQL
          ALTER TABLE distributors
            ADD CONSTRAINT zipchk
              CHECK (char_length(zipcode) = 5) NO INHERIT;
        SQL
      end
      dir.down do
        execute <<-SQL
          ALTER TABLE distributors
            DROP CONSTRAINT zipchk
        SQL
      end
    end

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end
end

Using reversible will ensure that the instructions are executed in the right order too. If the previous example migration is reverted, the down block will be run after the home_page_url column is removed and right before the table distributors is dropped.

Sometimes your migration will do something which is just plain irreversible; for example, it might destroy some data. In such cases, you can raise ActiveRecord::IrreversibleMigration in your down block. If someone tries to revert your migration, an error message will be displayed saying that it can't be done.


3.11 Using the up/down Methods

You can also use the old style of migration using up and down methods instead of the change method. The up method should describe the transformation you'd like to make to your schema, and the down method of your migration should revert the transformations done by the up method. In other words, the database schema should be unchanged if you do an up followed by a down. For example, if you create a table in the up method, you should drop it in the down method. It is wise to perform the transformations in precisely the reverse order they were made in the up method. The example in the reversible section is equivalent to:

class ExampleMigration < ActiveRecord::Migration[7.0]
  def up
    create_table :distributors do |t|
      t.string :zipcode
    end

    # add a CHECK constraint
    execute <<-SQL
      ALTER TABLE distributors
        ADD CONSTRAINT zipchk
        CHECK (char_length(zipcode) = 5);
    SQL

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end

  def down
    rename_column :users, :email_address, :email
    remove_column :users, :home_page_url

    execute <<-SQL
      ALTER TABLE distributors
        DROP CONSTRAINT zipchk
    SQL

    drop_table :distributors
  end
end

If your migration is irreversible, you should raise ActiveRecord::IrreversibleMigration from your down method. If someone tries to revert your migration, an error message will be displayed saying that it can't be done.

You can use Active Record's ability to rollback migrations using the revert method:

require_relative "20121212123456_example_migration"

class FixupExampleMigration < ActiveRecord::Migration[7.0]
  def change
    revert ExampleMigration

    create_table(:apples) do |t|
      t.string :variety
    end
  end
end


# Running Migrations
$ bin/rails db:migrate VERSION=20080906120000 to run that partcular timestamped migration

# rollback
$ bin/rails db:rollback

can add step also
$ bin/rails db:rollback STEP=3

redo rollsback migrations and executes them again (can also define step)

$ bin/rails db:redo STEP=3

4.2 Setup the Database

The bin/rails db:setup command will create the database, load the schema, and initialize it with the seed data.

The bin/rails db:reset command will drop the database and set it up again. This is functionally equivalent to bin/rails db:drop db:setup.

# running a specific migration
$ bin/rails db:migrate:up VERSION=20080906120000

If you want Active Record to not output anything, then running bin/rails db:migrate
VERBOSE=false will suppress all output.

Method |	Purpose
suppress_messages |	Takes a block as an argument and suppresses any output generated by the block.
say 	Takes a message argument and outputs it as is. A second boolean argument can be passed to specify whether to indent or not.
say_with_time |	Outputs text along with how long it took to run its block. If the block returns an integer it assumes it is the number of rows affected.

for ex:
class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    suppress_messages do
      create_table :products do |t|
        t.string :name
        t.text :description
        t.timestamps
      end
    end

    say "Created a table"

    suppress_messages {add_index :products, :name}
    say "and an index!", true

    say_with_time 'Waiting for a while' do
      sleep 10
      250
    end
  end
end

output:
==  CreateProducts: migrating =================================================
-- Created a table
   -> and an index!
-- Waiting for a while
   -> 10.0013s
   -> 250 rows
==  CreateProducts: migrated (10.0054s) =======================================


the db schema is stored in db/schema.rb