# ActiveRecord

## Model

  ```text
  -> business data which requires persistent storage
  +
  -> behavior which the data should exhibit
  ```

## ORM (Object Relational Mapping)

  Application Objets <=ORM=> RDBMS
  
  ActiveRecord is an ORM Framework which does the following
    - represents models & data
    - associations b/w models
    - validation of models
    - do DB ops on OOPS fashion

## Convention over configuration

  Naming Convention
    Book -> Model Class is CamelCase (singular)
    books -> DB table is snake_case (plural)
  
  Schema Conventions
    id: primary key, integer
    item_id: foreign key, references items table
    created_at, updated_at: timestamps
    lock_version: optimistic locking added to the model
    (assoc_name)_type: stores the type for polymorphic association
    (table_name)_count: Used to cache the number of belonging objects on associations. For example, a comments_count column in an Article class that has many instances of Comment will cache the number of existent comments for each article.

## Creating ActiveRecord Models

```ruby
class Product < ApplicationRecord
  self.table_name = 'other_table_name' # overrides tablename
  self.primary_key = 'key_name' # overrides primary key name viz. id
end
```

references products table)
products table =>

```sql
CREATE TABLE products(
  id int(11) PRIMARY KEY auto_increment
  name varchar(255)
);
```
  
`ApplicationRecord` inherits from `ActiveRecord::Base`
  
## CRUD

```ruby
#C
  user = User.create(name: 'Dave', occupation: 'Coder')
  create = new + save
  
#R
  User.all, User.first, User.last
  User.find_by(name: 'David')
  User.where(name: 'David').order_by(created_at: :desc)
  
#U
  User.find_by(name: 'David').update(name: 'Dave')
  User.update_all "SQL STRING"
  
#D
  User.find_by(...).destroy
  User.destroy_by(...)
  User.destory_all
```

## Covered In Depth Later

- Validations

  ``` ruby
  class User < ApplicationRecord
    validates :name, presence: true
  end
  
  # save -> returns false if validation fails
  # save! -> throws error if validation fails
  ```

- Callbacks

- Migrations
 DSL for defining tables

  ```ruby
    class CreatePublications < ActiveRecord::Migration[7.0]
      def change
        create_table :publications do |t|
          t.string :title
          t.text :description
          t.references :publication_type
          t.references :publisher, polymorphic: true
          t.boolean :single_issue

          t.timestamps
        end
      end
    end
  ```
