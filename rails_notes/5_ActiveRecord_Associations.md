# Associatons

## intro

Connection between two rails models

Without associations

```ruby
class Author < ApplicationRecord
end

class Book < ApplicationRecord
end

# on creating book for author
@book = Book.create(published_at: Time.now, author_id: @author.id)

# on deleting author, all ther books must be deleted
@books = Book.where(author_id: @author.id)
@books.each do |book|
  book.destroy
end
@author.destroy
```

but with associations, this becomes much more easier

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :destroy
end

class Book < ApplicationRecord
  belongs_to :author
end

# on creating a new book for an author
@book = @author.books.create(published_at: Time.now)

# on deleting author, all ther books must be deleted
@author.destroy
# this happens because of the dependent: :destroy option
```

## types of associoations

rails supports 6 types of associations

- `belongs_to`
- `has_one`
- `has_many`
- `has_many :through`
- `has_one :through`
- `has_and_belongs_to_many`

### `belongs_to`

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

in this example a book can only belong to one author

- NOTE: `belongs_to` association must have a singular name `:author` not `:authors`, this is because rails will automatically infer the table names

the corresponding migration would look like this:

```ruby
class CreateBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

```text
books: |id|author_id|published_at|timestamps|
            __|  
           v
authors: |id|name|timestamps|
```

- NOTE: `belongs_to` creates a one-directional, one-to-one connection in this example, the book knows the author, but the author does not know the book to setup a bidirectional connection we need to use `has_one` or `has_many` on the other model

- NOTE: `belongs_to` does not ensure referential integrity, so we may also need to add the `foreign_key: true` option to the `belongs_to` method

### `has_one`

one other model has a reference to this model

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

s = Supplier.first

a = supplier.account # account
```

```text
accounts: |id|supplier_id|timestamps|
              ____|  
             v
suppliers: |id|name|timestamps|
```

in this one we dont need to add the migration

### `has_many`

many other models have a reference to this model

```ruby
class Author < ApplicationRecord
  has_many :books
end

a = Author.first

b = Author.books # collection of books belonging to the author
```

```text
books: |id|author_id|published_at|timestamps|
            __|  
           v
authors: |id|name|timestamps|
```

### `has_many :through`

has a one to many association with another model using a third model

```ruby
class Physician < ApplicationRecord
  has_many :appointments
  has_many :patients, through: :appointments
end

class Appointment < ApplicationRecord
  belongs_to :physician
  belongs_to :patient
end

class Patient < ApplicationRecord
  has_many :appointments
  has_many :physicians, through: :appointments
end
```

```text
physicians: |id|name|
              ^__________________
                                 |
appointments: |id|patient_id|physician_id|time|
            ___________|
           v
patients: |id|name|
```

the migration looks like this

```ruby
class CreateAppointments < ActiveRecord::Migration[7.0]
  def change
    create_table :physicians do |t|
      t.string :name
      t.timestamps
    end

    create_table :patients do |t|
      t.string :name
      t.timestamps
    end

    create_table :appointments do |t|
      t.belongs_to :physician
      t.belongs_to :patient
      t.datetime :appointment_date
      t.timestamps
    end
  end
end
```

rails can automatically infer and create and destroy join models if needed when we use association methods

`phycisians.patients` and `phycisians.patients=` will use the `appointments` table to create and read `patients` table data and create seperate rows in `appointments` table

### `has_one :through`

has a one to one association with another model using a third model

```ruby
class Supplier < ApplicationRecord
  has_one :account
  has_one :account_history, through: :account
end

class Account < ApplicationRecord
  belongs_to :supplier
  has_one :account_history
end

class AccountHistory < ApplicationRecord
  belongs_to :account
end
```

```text
suppliers: |id|
             ^_____
                   |
accounts: |id|supplier_id|account_no|ts|
            ^____________
                         |
account_histories: |id|account_id|credit_rating|ts|
```

the migration looks like:

```ruby
class CreateAccountHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end

    create_table :account_histories do |t|
      t.belongs_to :account
      t.integer :credit_rating
      t.timestamps
    end
  end
end
```

### `has_and_belongs_to_many`

a many to many association between 2 models

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

```text
assemblies: |id|name|
             ^__________
                        |
assemblies_parts: |assembly_id|part_id|
          ________________________|
         v
parts: |id|name|
```

the migration for this would look like:

```ruby
class CreateAssembliesAndParts < ActiveRecord::Migration[7.0]
  def change
    create_table :assemblies do |t|
      t.string :name
      t.timestamps
    end

    create_table :parts do |t|
      t.string :part_number
      t.timestamps
    end

    create_table :assemblies_parts, id: false do |t|
      t.belongs_to :assembly
      t.belongs_to :part
    end
    
    # we can also make a join table for the last one

    create_join_table :assemblies, :parts do |t|
      # t.index [assembly_id, part_id]
      # t.index [part_id, assembly_id]
    end
  end
end
```

### `polymorphic`

```ruby
class Picture < ApplicationRecord
  belongs_to :imageable, polymorphic: true
end

class Employee < ApplicationRecord
  has_many :pictures, as: :imageable
end

class Product < ApplicationRecord
  has_many :pictures, as: :imageable
end
```

the migration is

```ruby
class CreatePictures < ActiveRecord::Migration[7.0]
  def change
    create_table :pictures do |t|
      t.string  :name
      t.bigint  :imageable_id
      t.string  :imageable_type
      t.timestamps
    end

    add_index :pictures, [:imageable_type, :imageable_id]
  end
end

# we can also write it like this

class CreatePictures < ActiveRecord::Migration[7.0]
  def change
    create_table :pictures do |t|
      t.string :name
      t.references :imageable, polymorphic: true
      t.timestamps
    end
  end
end
```

```text
employees: |id|name|
            ^______________________
                                   |
pictures: |id|imageable_type|imageable_id|
             ______________________|
            v
products: |id|name|
```

### self joins

Employees have managers who themselves are employees

```ruby
class Employee < ApplicationRecord
  has_many :subordinates, class_name: "Employee",
                          foreign_key: "manager_id"

  belongs_to :manager, class_name: "Employee", optional: true # is now false by default was true on older versions
end
```

the migration for this is

```ruby
class CreateEmployees < ActiveRecord::Migration[7.0]
  def change
    create_table :employees do |t|
      t.references :manager, foreign_key: { to_table: :employees }
      t.timestamps
    end
  end
end
```

```text
employees: |id|name|manager_id|
            ^_____________|
```

## Tips, Tricks, and Warnings

### controlling caching

by default all methods are cached in production, in developent we can toggle caching by `rails dev:cache`

```ruby
# retrieves books from the database
author.books.load

# uses the cached copy of books
author.books.size

# uses the cached copy of books
author.books.empty?

# we can reload the cache, for ex if the db has changed
author.books.reload.empty?
```

### avoiding name collisions

You are not free to use just any name for your associations. Because creating an association adds a method with that name to the model, it is a bad idea to give an association a name that is already used for an instance method of `ActiveRecord::Base`. The association method would override the base method and break things. For instance, `attributes` or `connection` are bad names for associations.

### updatting the schema

For `belongs_to` associations you need to create foreign keys, and for `has_and_belongs_to_many` associations you need to create the appropriate join table.

#### creating references for `belongs_to`

let us take this model

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

we need to create an appropriate migration for it

```ruby
# NOTE: references is also aliased as belongs_to
# NOTE: add_reference is also aliased as add_belongs_to

class CreateBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :books do |t|
      t.datetime   :published_at
      t.string     :book_number
      t.references :author
      # can also add fk for ref integrity
      # t.references :author, foreign_key: true
    end
  end
end


# if the table books already exists then

class AddAuthorToBooks < ActiveRecord::Migration[7.0]
  def change
    add_reference :books, :author
    # can also add fk for ref integrity
    # add_reference :books, :author, foreign_key: true
  end
end
```

#### creating join tables for `has_and_belongs_to_many`

for this model association

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

`ActiveRecord` will look for a table with the name using an algorithm like `['Part', 'Assembly'].map(&:downcase).map(&:pluralize).sort.join('_')`, which evaluates to `assemblies_parts`

we now need to create this table

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_table :assemblies_parts, id: false do |t|
      t.bigint :assembly_id
      t.bigint :part_id
    end

    add_index :assemblies_parts, :assembly_id
    add_index :assemblies_parts, :part_id
  end
end

# or

class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :assemblies, :parts do |t|
      t.index :assembly_id
      t.index :part_id
    end
  end
end
```

- NOTE: if we do not want the table name to be this, we can pass a table name of our choice using the `join_table:` option

  ```ruby
  class Assembly < ApplicationRecord
    has_and_belongs_to_many :parts, join_table: :fittings
  end

  class Part < ApplicationRecord
    has_and_belongs_to_many :assemblies, join_table: :fittings
  end
  ```

  remember to make this table in the migration

  ```ruby
  create_join_table :assemblies, :parts, table_name: :fittings do |t|
    t.index :assembly_id
    t.index :part_id
  end

  # or

  class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.0]
    def change
      create_table :fittings, id: false do |t|
        t.bigint :assembly_id
        t.bigint :part_id
      end

      add_index :fittings, :assembly_id
      add_index :fittings, :part_id
    end
  end
  ```

### controlling assiciation scope

by default associations look for objects only within the scope of the current module

- NOTE: WORKS THE SAME AS CONSTANT LOOKUP, ONLY DIFFERENCE IS THAT EACH MODEL MUST BE ABLE TO LOOKUP THE OTHER

so this works:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end

    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

but this does not:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end

s = MyApplication::Business::Supplier.last

s.account # gives the follwing error

#  Rails couldn't find a valid model for Account association. Please provide the :class_name option on the association declaration. If :class_name is already provided, make sure it's an ActiveRecord::Base subclass. (NameError)
```

to associate with a model in a different namespace, we must specify the full classname in the `class_name:` option in `belongs_to` and `has_one/has_many`

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account,
        class_name: "MyApplication::Billing::Account"
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier,
        class_name: "MyApplication::Business::Supplier"
    end
  end
end
```

### bidirectional associations

associations need to work in both directions, so let us say we have an association

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
end
```

`ActiveRecord` automatically infer that these 2 models have an association so will load only once copy of the author object when referenced by multiple of his books

```bash
irb> a = Author.first
irb> b = a.books.first
irb> a.first_name == b.author.first_name
=> true
irb> a.first_name = 'David'
irb> a.first_name == b.author.first_name
=> true
```

`ActiveRecord` will not automatically identify bi-directional associations that contain the `:through` or `:foreign_key` options. Custom scopes on the opposite association also prevent automatic identification, as do custom scopes on the association itself unless `config.active_record.automatic_scope_inversing` is set to `true`

for example

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

```bash
irb> a = Author.first
irb> b = a.books.first
irb> a.first_name == b.writer.first_name
=> true
irb> a.first_name = 'David'
irb> a.first_name == b.writer.first_name
=> false
```

to make `ActiveRecord` recognise these bidirectional associations, we use the `inverse_of:` option when declaring `has_one/has_many`

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: 'writer'
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

```bash
irb> a = Author.first
irb> b = a.books.first
irb> a.first_name == b.author.first_name
=> true
irb> a.first_name = 'David'
irb> a.first_name == b.author.first_name
=> true
```

## Association Reference

### `belongs_to` reference

#### methods added to class by `belongs_to`

there are 8 methods:

- `association`
  
   returns the associated object, if any. If no associated object is found, it returns `nil`.

    ```ruby
    @author = @book.author
    ```

    If the associated object has already been retrieved from the database for this object, the cached version will be returned. To override this behavior (and force a database read), call `#reload_association` on the parent object.

    ```ruby
    @author = @book.reload_author
    ```

- `association=(associate)`
  
    assigns an associated object to this object. Behind the scenes, this means extracting the primary key from the associated object and setting this object's foreign key to the same value.

    ```ruby
    @book.author = @author
    ```

- `build_association(attributes = {})`

    returns a new object of the associated type. This object will be instantiated from the passed attributes, and the link through this object's foreign key will be set, but the associated object will **not** yet be saved.

    ```ruby
    @author = @book.build_author(author_number: 123, author_name: "John Doe")
    ```

- `create_association(attributes = {})`

    returns a new object of the associated type. This object will be instantiated from the passed attributes, the link through this object's foreign key will be set, and, once it passes all of the validations specified on the associated model, the associated object will be saved, else will return `false`.

    ```ruby
    @author = @book.create_author(author_number: 123, author_name: "John Doe")
    ```

- `create_association!(attributes = {})`

    same as `create_association(attributes = {})` but in this case raises `ActiveRecord::RecordInvalid` if the record is invalid

- `reload_association`
- `association_changed?`
  
    returns `true` if a new associated object has been assigned and the foreign key will be updated in the next save.

    ```ruby
    @book.author # => #<Book author_number: 123, author_name: "John Doe">
    @book.author_changed? # => false

    @book.author = Author.second # => #<Book author_number: 456, author_name: "Jane Smith">
    @book.author_changed? # => true

    @book.save!
    @book.author_changed? # => false
    ```

- `association_previously_changed?`

    returns `true` if the previous save updated the association to reference a new associate object.

    ```ruby
    @book.author # => #<Book author_number: 123, author_name: "John Doe">
    @book.author_previously_changed? # => false

    @book.author = Author.second # => #<Book author_number: 456, author_name: "Jane Smith">
    @book.save!
    @book.author_previously_changed? # => true
    ```

#### options for `belongs_to`

the following options are supported

- `:autosave`

    If you set the `:autosave` option to `true`, Rails will save any loaded association members and destroy members that are marked for destruction whenever you save the parent object. Setting `:autosave` to `false` is **not** the same as not setting the `:autosave` option. If the `:autosave` option is not present, then new associated objects will be saved, but updated associated objects will not be saved.

    when an objects `_destroy` key is set to true the `marked_for_destruction?` method will return true

- `:class_name`

    If the name of the other model cannot be derived from the association name, you can use the `:class_name` option to supply the model name. For example, if a book belongs to an author, but the actual name of the model containing authors is `Patron`, you'd set things up this way:

    ```ruby
    class Book < ApplicationRecord
      belongs_to :author, class_name: "Patron"
    end
    ```

- `:counter_cache`

    this option can be used to make finding the number of belonging objects efficiently

    in a normal scenario

    ```ruby
    class Author < ApplicationRecord
      has_many :books
    end

    class Book < ApplicationRecord
      belongs_to :author
    end

    a = Author.first

    a.books.size # calls a COUNT(*) query in the db
    ```

    to avoid this call to db we can add `counter_cache: true` on the `belongs_to` side of the association, which will add a column named `books_count` on the `Author` model

    ```ruby
    class Author < ApplicationRecord
      has_many :books
    end

    class Book < ApplicationRecord
      belongs_to :author, counter_cache: true
      # belongs_to :author, counter_cache: :count_of_books
      # creates column named count_of_books in the Author table
    end

    a = Author.first

    a.books.size # reads from the books_count column
    ```

- `:dependent`

    we can set the `:dependent` option to the following:

  - `:destroy`, when this object is destroyed, run the `destroy` method of the associatied object(s)

  - `:delete`, when this object is destroyed, will directly delete all associated object(s) from db w/o calling `destroy` on them

  - `:destroy_asyc`, when this object is destroyed an     `ActiveRecord::DestroyAssociationAsyncJob` job is enqueued which will call destroy on its associated objects. Active Job must be set up for this to work.

    NOTE: do not use this option on the `belongs_to` side of a many to one operation as that may lead to deleting the associated object of other objects and having orphaned records in the db

- `:foreign_key`

    by convention Rails will take the name of the foreign key as the associated model name suffixed with `_id`, but this option allows you to override it

    ```ruby
    class Book < ApplicationRecord
      belongs_to :author, class_name: "Patron",
                          foreign_key: "patron_id"
    end
    ```

- `:foreign_type`*
    Specify the column used to store the associated object's type, if this is a polymorphic association. By default this is guessed to be the name of the association with a `_type` suffix. So a class that defines a `belongs_to :taggable, polymorphic: true` association will use `taggable_type` as the default `:foreign_type`.

- `:primary_key`

    by convention rails will take the `id` column to be primary key, this option allows you to set a different column

    ```ruby
    class User < ApplicationRecord
      self.primary_key = 'guid' # primary key is guid and not id
    end

    class Todo < ApplicationRecord
      belongs_to :user, primary_key: 'guid'
    end

    @todo.user_id # will reference @user.guid
    ```

- `:inverse_of`

    specifies the name of the `has_one/many` option in the inverse of the association

    ```ruby
    class Author < ApplicationRecord
      has_many :books, inverse_of: :author
    end

    class Book < ApplicationRecord
      belongs_to :author, inverse_of: :books
    end
    ```

- `:polymorphic`

    set `true` to indicate a polymorphic relation

    [Polymorphic Relations](#polymorphic)

- `:touch`

    when set to `true` will change `update_at/on` column of the associated object to current time whenever this object is saved or destroyed

- `:validate`

    when `true` will run validations for the associated object, defaults to `false`

- `:optional`

    when `true` will not check for presence of associated object, defaults to `false`, defaulted to `true` on older versions

- `:default`*
    Provide a callable (i.e. `proc` or `lambda`) to specify that the association should be initialized with a particular record before validation.

    ```ruby
    belongs_to :account, default: -> { company.account }
    ```

- `:strict_loading`*
    Enforces strict loading every time the associated record is loaded through this association.

- `:ensuring_owner_was`*
    Specifies an instance method to be called on the owner. The method must return `true` in order for the associated records to be deleted in a background job.

#### scopes for `belongs_to`

There may be times when you wish to customize the query used by `belongs_to`. Such customizations can be achieved via a scope block, inside it a method from query interface will be used

For example:

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

this can be done by using query methods inside the block, which include

- `where`
  
    conditions that associated object must meet

    ```ruby
    class Book < ApplicationRecord
      belongs_to :author, -> { where active: true }
    end
    ```

- `includes`

    used to specify second-order associations (associated to the associated object of this object) that should be eager loaded when the association is used

    for ex:

    ```ruby
    class Chapter < ApplicationRecord
      belongs_to :book
    end

    class Book < ApplicationRecord
      belongs_to :author
      has_many :chapters
    end

    class Author < ApplicationRecord
      has_many :books
    end

    # if we freuently use @chapter.book.author, it has to be loaded from database so we can make it efficient by using

    class Chapter < ApplicationRecord
      belongs_to :book, -> { includes :author }
    end
    ```

    NOTE: we do not need `includes` for 2 directly associated models

- `readonly`

    the associated object will be retrieved from db as a Read Only object

- `select`

    The `select` method lets you override the SQL `SELECT` clause that is used to retrieve data about the associated object. By default, Rails retrieves all columns.

    NOTE: If you use the `select` method on a `belongs_to` association, you should also set the `:foreign_key` option to guarantee the correct results.

#### `belongs_to` existence of associated objects

```ruby
if @book.author.nil?
  @msg = "No author found for this book"
end
```

#### `belongs_to` when is the object saved?

Assigning an object to a `belongs_to` association does **not** automatically save the object. It does **not** save the associated object either.

- NOTE: When initializing a new `has_one` or `belongs_to` association you must use the `build_` prefix to build the association, rather than the `association.build` method that would be used for `has_many` or `has_and_belongs_to_many` associations. To create one, use the `create_` prefix.

### `has_one` reference

#### methods added to the class by `has_one`

there are 7 methods:

- `association`

    returns the associated object, if any. If no associated object is found, it returns `nil`.

    ```ruby
    @account = @supplier.account
    ```

    If the associated object has already been retrieved from the database for this object, the cached version will be returned. To override this behavior (and force a database read), call `#reload_association` on the parent object.

    ```ruby
    @account = @supplier.reload_account
    ```

- `association=(associate)`

     assigns an associated object to this object. Behind the scenes, this means extracting the primary key from this object and setting the associated object's foreign key to the same value.

    ```ruby
    @ = @author
    ```

- `build_association(attributes = {})`
     returns a new object of the associated type. This object will be instantiated from the passed attributes, and the link through the associated object's foreign key will be set, but the associated object will **not** yet be saved.

    ```ruby
    @account = @supplier.build_account(terms: "Net 30")
    ```

- `create_association(attributes = {})`

    returns a new object of the associated type. This object will be instantiated from the passed attributes, the link through its foreign key will be set, and, once it passes all of the validations specified on the associated model, the associated object will be saved.

    ```ruby
    @account = @supplier.create_account(terms: "Net 30")
    ```

- `create_association!(attributes = {})`
  
    Does the same as `create_association` above, but raises `ActiveRecord::RecordInvalid` if the record is invalid.

- `reload_association`

#### options for `has_one`

the following options are supported

- `:as`

    indicates that this is a polymorphic association

    [Polymorphic Associations](#polymorphic)

- `:autosave`

    If you set the :`autosave` option to `true`, Rails will save any loaded association members and destroy members that are marked for destruction whenever you save the parent object. Setting `:autosave` to `false` is **not** the same as not setting the `:autosave` option. If the `:autosave` option is not present, then new associated objects will be saved, but updated associated objects will not be saved.

    when an objects `_destroy` key is set to true the `marked_for_destruction?` method will return true

- `:class_name`

    If the name of the other model cannot be derived from the association name, you can use the `:class_name` option to supply the model name. For example, if a supplier has an account, but the actual name of the model containing accounts is `Billing`, you'd set things up this way:

    ```ruby
    class Supplier < ApplicationRecord
      has_one :account, class_name: "Billing"
    end
    ```

- `:dependent`

    we can set the `:dependent` option to the following:

  - `:destroy` causes the associated object to also be destroyed

  - `:delete` causes the associated object to be deleted directly from the database (so callbacks will not execute)

  - `:destroy_async`: when the object is destroyed, an `ActiveRecord::DestroyAssociationAsyncJob` job is enqueued which will call destroy on its associated objects. Active Job must be set up for this to work.
  
  - `:nullify` causes the foreign key to be set to `NULL`. Polymorphic type column is also nullified on polymorphic associations. Callbacks are not executed.

  - `:restrict_with_exception` causes an `ActiveRecord::DeleteRestrictionError` exception to be raised if there is an associated record

  - `:restrict_with_error` causes an error to be added to the owner if there is an associated object

    NOTE: It's necessary not to set or leave `:nullify` option for those associations that have `NOT NULL` database constraints. If you don't set `dependent` to `destroy` such associations you won't be able to change the associated object because the initial associated object's foreign key will be set to the unallowed `NULL` value.

- `:foreign_key`

    by convention Rails will take the name of the foreign key as the associated model name suffixed with `_id`, but this option allows you to override it

    ```ruby
    class Supplier < ApplicationRecord
      has_one :account, foreign_key: "supp_id"
    end
    ```

- `:inverse_of`

    specifies the name of the `belongs_to` association that is the inverse of this association.

    ```ruby
    class Supplier < ApplicationRecord
      has_one :account, inverse_of: :supplier
    end

    class Account < ApplicationRecord
      belongs_to :supplier, inverse_of: :account
    end
    ```

- `:primary_key`

    By convention, Rails assumes that the column used to hold the primary key of this model is `id`. You can override this and explicitly specify the primary key with the `:primary_key` option.

- `:source`

    The `:source` option specifies the source association name for a `has_one :through` association.

- `:source_type`

    The `:source_type` option specifies the source association type for a `has_one :through` association that proceeds through a `polymorphic` association.

    ```ruby
    class Author < ApplicationRecord
      has_one :book
      has_one :hardback, through: :book, source: :format, source_type: "Hardback"
      has_one :dust_jacket, through: :hardback
    end

    class Book < ApplicationRecord
      belongs_to :format, polymorphic: true
    end

    class Paperback < ApplicationRecord; end

    class Hardback < ApplicationRecord
      has_one :dust_jacket
    end

    class DustJacket < ApplicationRecord; end
    ```

- `:through`

    specifies a join model through which to perform the query

    [`has_one :through`](#has_one-through)

- `:touch`

    when set to `true` will change `update_at/on` column of the associated object to current time whenever this object is saved or destroyed

- `:validate`

    If you set the `:validate` option to `true`, then new associated objects will be validated whenever you save this object. By default, this is `false`: new associated objects will not be validated when this object is saved.

- `:disable_joins`*

    Specifies whether joins should be skipped for an association. If set to `true`, two or more queries will be generated. Note that in some cases, if order or limit is applied, it will be done in-memory due to database limitations. This option is only applicable on `has_one :through` associations as `has_one` alone does not perform a join.

- `:required`*

    When set to `true`, the association will also have its presence validated. This will validate the association itself, not the id. You can use `:inverse_of` to avoid an extra query during validation.

- `:strict_loading`*
    Enforces strict loading every time the associated record is loaded through this association.

- `:ensuring_owner_was`*
    Specifies an instance method to be called on the owner. The method must return `true` in order for the associated records to be deleted in a background job.

#### scopes for `has_one`

There may be times when you wish to customize the query used by `has_one`. Such customizations can be achieved via a scope block. For example:

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where active: true }
end
```

this can be done by using query methods inside the block, which include

- `where`
- `includes`
- `readonly`
- `select`

#### `has_one` existence of associated objects

```ruby
if @supplier.account.nil?
  @msg = "No account found for this supplier"
end
```

#### `has_one` when is the object saved?

When you assign an object to a `has_one` association, that object is automatically saved (in order to update its foreign key). In addition, any object being replaced is also automatically saved, because its foreign key will change too.

If either of these saves fails due to validation errors, then the assignment statement returns false and the assignment itself is cancelled.

If the parent object (the one declaring the has_one association) is unsaved (that is, `new_record?` returns true) then the child objects are not saved. They will automatically when the parent object is saved.

If you want to assign an object to a `has_one` association without saving the object, use the `build_association` method.

### `has_many` reference

#### methods added to the class by `has_many`

there are 17 methods:

- `collection`

  returns a Relation of all of the associated objects. If there are no associated objects, it returns an empty Relation.

  ```ruby
  @books = @author.books
  ```

- `collection<<(object, ...)`

    adds one or more objects to the collection by setting their foreign keys to the primary key of the calling model.

    ```ruby
    @author.books << @book1
    ```

- `collection.delete(object, ...)`

    removes one or more objects from the collection by setting their foreign keys to `NULL`.

    ```ruby
    @author.books.delete(@book1)
    ```

    NOTE: Additionally, objects will be destroyed if they're associated with `dependent: :destroy`, and deleted if they're associated with `dependent: :delete_all`.

- `collection.destroy(object, ...)`

    removes one or more objects from the collection by running destroy on each object.

    ```ruby
    @author.books.destroy(@book1)
    ```

    NOTE: Objects will always be removed from the database, ignoring the `:dependent` option.

- `collection=(objects)`

    makes the collection contain only the supplied objects, by adding and deleting as appropriate. The changes are persisted to the database.

- `collection_singular_ids`

    The `collection_singular_ids` method returns an array of the ids of the objects in the collection.

    ```ruby
    @book_ids = @author.book_ids
    ```

- `collection_singular_ids=(ids)`

    makes the collection contain only the objects identified by the supplied primary key values, by adding and deleting as appropriate. The changes are persisted to the database.

- `collection.clear`

    removes all objects from the collection according to the strategy specified by the `dependent` option. If no option is given, it follows the default strategy. The default strategy for `has_many :through` associations is `delete_all`, and for `has_many` associations is to set the foreign keys to `NULL`.

    ```ruby
    @author.books.clear
    ```

- `collection.empty?`

    returns `true` if the collection does not contain any associated objects.

    ```erb
    <% if @author.books.empty? %>
      No Books Found
    <% end %>
    ```

- `collection.size`

    returns the number of objects in the collection.

    ```ruby
    @book_count = @author.books.size
    ```

- `collection.find(...)`

    finds objects within the collection's table.

    ```ruby
    @available_book = @author.books.find(1) # only works if the current author's book has id of 1
    ```

- `collection.where(...)`

    finds objects within the collection based on the conditions supplied but the objects are loaded lazily meaning that the database is queried only when the object(s) are accessed.

    ```ruby
    @available_books = @author.books.where(available: true) # No query yet
    @available_book = @available_books.first # Now the database will be queried
    ```

- `collection.exists?(...)`

    checks whether an object meeting the supplied conditions exists in the collection's table.

- `collection.build(attributes = {})`

    returns a single or array of new objects of the associated type. The object(s) will be instantiated from the passed attributes, and the link through their foreign key will be created, but the associated objects will **not** yet be saved.

    ```ruby
    @book = @author.books.build(published_at: Time.now,
                                book_number: "A12345")

    @books = @author.books.build([
      { published_at: Time.now, book_number: "A12346" },
      { published_at: Time.now, book_number: "A12347" }
    ])
    ```

- `collection.create(attributes = {})`
    returns a single or array of new objects of the associated type. The object(s) will be instantiated from the passed attributes, the link through its foreign key will be created, and, once it passes all of the validations specified on the associated model, the associated object will be saved.

    ```ruby
    @book = @author.books.create(published_at: Time.now,
                                book_number: "A12345")

    @books = @author.books.create([
      { published_at: Time.now, book_number: "A12346" },
      { published_at: Time

    .now, book_number: "A12347" }
    ])
    ```

- `collection.create!(attributes = {})`

    Does the same as `collection.create` above, but raises `ActiveRecord::RecordInvalid` if the record is invalid.

- `collection.reload`

    returns a Relation of all of the associated objects, forcing a database read. If there are no associated objects, it returns an empty Relation.

    ```ruby
    @books = @author.books.reload
    ```

#### options for `has_many`

- `:as`

  polymorphic association

- `:autosave`

  If you set the `:autosave` option to `true`, Rails will save any loaded association members and destroy members that are marked for destruction whenever you save the parent object. Setting `:autosave` to `false` is **not** the same as not setting the `:autosave` option. If the `:autosave` option is not present, then new associated objects will be saved, but updated associated objects will not be saved.

  when an objects `_destroy` key is set to true the `marked_for_destruction?` method will return true

- `:class_name`

  If the name of the other model cannot be derived from the association name, you can use the `:class_name` option to supply the model name

- `:counter_cache`

  This option can be used to configure a custom named `:counter_cache`. You only need this option when you customized the name of your `:counter_cache` on the `belongs_to` association.

- `:dependent`

  we can set the `:dependent` option to the following:

  - `:destroy` causes the associated objects to also be destroyed

  - `:delete_all` causes the associated objects to be deleted directly from the database (so callbacks will not execute)

  - `:destroy_async`: when the objects are destroyed, an `ActiveRecord::DestroyAssociationAsyncJob` job is enqueued which will call destroy on its associated objects. Active Job must be set up for this to work.
  
  - `:nullify` causes the foreign key to be set to `NULL`. Polymorphic type column is also nullified on polymorphic associations. Callbacks are not executed.

  - `:restrict_with_exception` causes an `ActiveRecord::DeleteRestrictionError` exception to be raised if there is an associated record

  - `:restrict_with_error` causes an error to be added to the owner if there is an associated object

  NOTE: The `:destroy` and `:delete_all` options also affect the semantics of the collection.delete and collection= methods by causing them to destroy associated objects when they are removed from the collection.

- `:foreign_key`

  By convention, Rails assumes that the column used to hold the foreign key on the other model is the name of this model with the suffix `_id` added. The `:foreign_key` option lets you set the name of the foreign key directly:

  ```ruby
  class Author < ApplicationRecord
    has_many :books, foreign_key: "cust_id"
  end
  ```

- `:inverse_of`

  specifies the name of the belongs_to association that is the inverse of this association.

  ```ruby
  class Author < ApplicationRecord
    has_many :books, inverse_of: :author
  end

  class Book < ApplicationRecord
    belongs_to :author, inverse_of: :books
  end
  ```

- `:primary_key`

  By convention, Rails assumes that the column used to hold the primary key of the association is `id`. You can override this and explicitly specify the primary key with the `:primary_key` option.

  Let's say the users table has `id` as the primary_key but it also has a `guid` column. The requirement is that the todos table should hold the `guid` column value as the foreign key and not `id` value. This can be achieved like this:

  ```ruby
  class User < ApplicationRecord
    has_many :todos, primary_key: :guid
  end
  ```

  Now if we execute `@todo = @user.todos.create` then the `@todo` record's `user_id` value will be the `guid` value of `@user`.

- `:source`

  specifies the source association name for a `has_many :through` association. You only need to use this option if the name of the source association cannot be automatically inferred from the association name.

- `:source_type`

  specifies the source association type for a has_many :through association that proceeds through a polymorphic association.

  ```ruby
  class Author < ApplicationRecord
    has_many :books
    has_many :paperbacks, through: :books, source: :format, source_type: "Paperback"
  end

  class Book < ApplicationRecord
    belongs_to :format, polymorphic: true
  end


  class Hardback < ApplicationRecord; end
  class Paperback < ApplicationRecord; end
  ```

- `:through`

  specifies a join model through which to perform the query. has_many :through associations provide a way to implement many-to-many relationships

  [`has_many :through`](#has_many-through)

- `:validate`

  If you set the `:validate` option to `false`, then new associated objects will not be validated whenever you save this object. By default, this is `true`: new associated objects will be validated when this object is saved.

#### scopes for `has_many`

- `where`
- `extending`
- `group`
- `includes`
- `limit`
- `offset`
- `order`
- `readonly`
- `select`
- `distinct`

#### `has_many` when is the object saved?

When you assign an object to a has_many association, that object is automatically saved (in order to update its foreign key). If you assign multiple objects in one statement, then they are all saved.

If any of these saves fails due to validation errors, then the assignment statement returns false and the assignment itself is cancelled.

If the parent object (the one declaring the has_many association) is unsaved (that is, new_record? returns true) then the child objects are not saved when they are added. All unsaved members of the association will automatically be saved when the parent is saved.

If you want to assign an object to a has_many association without saving the object, use the collection.build method.

### `has_and_belongs_to_many` reference

#### methods added by `has_and_belongs_to_many`

these methods are added:

- `collection`
- `collection<<(object, ...)`
- `collection.delete(object, ...)`
- `collection.destroy(object, ...)`
- `collection=(objects)`
- `collection_singular_ids`
- `collection_singular_ids=(ids)`
- `collection.clear`
- `collection.empty?`
- `collection.size`
- `collection.find(...)`
- `collection.where(...)`
- `collection.exists?(...)`
- `collection.build(attributes = {})`
- `collection.create(attributes = {})`
- `collection.create!(attributes = {})`
- `collection.reload`

NOTE: ADDING ADDITIONAL COLUMNS TO JOIN TABLE IS DEPRECATED

#### options for `has_and_belongs_to_many`

these options are supported:

- `:association_foreign_key`

  By convention, Rails assumes that the column in the join table used to hold the foreign key pointing to the other model is the name of that model with the suffix _id added. The :association_foreign_key

- `:autosave`
- `:class_name`

  If the name of the other model cannot be derived from the association name, you can use the :class_name option to supply the model name. For example, if a part has many assemblies, but the actual name of the model containing assemblies is Gadget, you'd set things up this way:

  ```ruby
  class Parts < ApplicationRecord
    has_and_belongs_to_many :assemblies, class_name: "Gadget"
  end
  ```

- `:foreign_key`

  By convention, Rails assumes that the column in the join table used to hold the foreign key pointing to this model is the name of this model with the suffix _id added. The :foreign_key option lets you set the name of the foreign key directly:

  ```ruby
  class User < ApplicationRecord
    has_and_belongs_to_many :friends,
        class_name: "User",
        foreign_key: "this_user_id",
        association_foreign_key: "other_user_id"
  end
  ```

- `:join_table`

  If the default name of the join table, based on lexical ordering, is not what you want, you can use the :join_table option to override the default.

- `:validate`

  If you set the :validate option to false, then new associated objects will not be validated whenever you save this object. By default, this is true: new associated objects will be validated when this object is saved.

#### scopes for `has_and_belongs_to_many`

- `where`
- `extending`
- `group`
- `includes`
- `limit`
- `offset`
- `order`
- `readonly`
- `select`
- `distinct`

#### `has_and_belongs_to_many` when is the object saved?

When you assign an object to a has_and_belongs_to_many association, that object is automatically saved (in order to update the join table). If you assign multiple objects in one statement, then they are all saved.

If any of these saves fails due to validation errors, then the assignment statement returns false and the assignment itself is cancelled.

If the parent object (the one declaring the has_and_belongs_to_many association) is unsaved (that is, new_record? returns true) then the child objects are not saved when they are added. All unsaved members of the association will automatically be saved when the parent is saved.

If you want to assign an object to a has_and_belongs_to_many association without saving the object, use the collection.build method.

### Association Callbacks

There are four available association callbacks:

- `before_add`
- `after_add`
- `before_remove`
- `after_remove`

```ruby
class Author < ApplicationRecord
  has_many :books, before_add: :check_credit_limit # can also add an array to callbacks

  def check_credit_limit(book)
    # ...
  end
end
```

### Association Extensions

## Single Table Inheritence (STI)

Sometimes, you may want to share fields and behavior between different models. Let's say we have Car, Motorcycle, and Bicycle models. We will want to share the color and price fields and some methods for all of them, but having some specific behavior for each, and separated controllers too.

First, let's generate the base Vehicle model:

`$ bin/rails generate model vehicle type:string color:string price:decimal{10.2}`

Did you note we are adding a "type" field? Since all models will be saved in a single database table, Rails will save in this column the name of the model that is being saved. In our example, this can be "Car", "Motorcycle" or "Bicycle." STI won't work without a "type" field in the table.

Next, we will generate the Car model that inherits from Vehicle. For this, we can use the --parent=PARENT option, which will generate a model that inherits from the specified parent and without equivalent migration (since the table already exists).

For example, to generate the Car model:

`$ bin/rails generate model car --parent=Vehicle`

The generated model will look like this:

```ruby
class Car < Vehicle
end
```

This means that all behavior added to Vehicle is available for Car too, as associations, public methods, etc.

Creating a car will save it in the vehicles table with "Car" as the type field:

```ruby
Car.create(color: 'Red', price: 10000)
```

will generate the following SQL:

```sql
INSERT INTO "vehicles" ("type", "color", "price") VALUES ('Car', 'Red', 10000)
```

Querying car records will search only for vehicles that are cars:

```ruby
Car.all
```

will run a query like:

```sql
SELECT "vehicles".* FROM "vehicles" WHERE "vehicles"."type" IN ('Car')
```
