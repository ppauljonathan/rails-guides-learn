# Query Interface

## intro

we can use rails to do our SQL queries for us

## retrieving data

the methods available are:

- `annotate`
- `find`
- `create_with`
- `distinct`
- `eager_load`
- `extending`
- `extract_associated`
- `from`
- `group`
- `having`
- `includes`
- `joins`
- `left_outer_joins`
- `limit`
- `lock`
- `none`
- `offset`
- `optimizer_hints`
- `order`
- `preload`
- `readonly`
- `references`
- `reorder`
- `reselect`
- `reverse_order`
- `select`
- `where`

### retreiving single objects

- `find`
  
  retrieve object corresponding to the specified primary key

  ```ruby
  customer = Customer.find(10) # customer_id 10
  ```

  ```sql
  SELECT * FROM customers WHERE (customers.id = 10) LIMIT 1
  ```

  The `find` method will raise an `ActiveRecord::RecordNotFound` exception if no matching record is found.

  we can also pass an array of primary keys

  ```ruby
    customers = Customer.find([1, 10]) # OR Customer.find(1, 10)
  ```

  ```sql
  SELECT * FROM customers WHERE (customers.id IN (1,10))
  ```

  The `find` method will raise an `ActiveRecord::RecordNotFound` exception unless a matching record is found for **all** of the supplied primary keys.

- `take`

  retreives a record **without** any ordering

  ```ruby
  customer = Customer.take
  ```

  ```sql
  SELECT * FROM customers LIMIT 1
  ```

  if we pass an argument of `take` this changes the `LIMIT` in the sql query

  the `take` method returns `nil` when the record is not found

  the `take!` method throws `ActiveRecord::RecordNotFound` exception when record is not found

- `first`
  
  The `first` method finds the first record ordered by primary key (default)

  ```ruby
  customer = Customer.first
  ```

  ```sql
  SELECT * FROM customers ORDER BY customers.id ASC LIMIT 1
  ```

  The `first` method returns `nil` if no matching record is found and no exception will be raised.

  If your default scope contains an `order` method, `first` will return the first record according to this ordering.

  You can pass in a numerical argument to the `first` method to return up to that number of results.

  The `first!` method behaves exactly like `first`, except that it will raise `ActiveRecord::RecordNotFound` if no matching record is found.

- `last`

  The `last` method finds the last record ordered by primary key (default)

  ```ruby
  customer = Customer.last
  ```

  ```sql
  SELECT * FROM customers ORDER BY customers.id DESC LIMIT 1
  ```

  The `last` method returns `nil` if no matching record is found and no exception will be raised.

  If your default scope contains an `order` method, `last` will return the last record according to this ordering.

  You can pass in a numerical argument to the `last` method to return up to that number of results.

  The `last!` method behaves exactly like `last`, except that it will raise `ActiveRecord::RecordNotFound` if no matching record is found.

- `find_by`

  finds the first record which matches the given conditions

  ```ruby
  Customer.find_by first_name: 'Lifo'

  # equivalent
  Customer.where(first_name: 'Lifo').take
  ```

  ```sql
  SELECT * FROM customers WHERE (customers.first_name = 'Lifo') LIMIT 1
  ```

  Note that there is no `ORDER BY` in the above SQL. If your `find_by` conditions can match multiple records, you should apply an `order` to guarantee a deterministic result.

  The `find_by!` method behaves exactly like `find_by`, except that it will raise `ActiveRecord::RecordNotFound` if no matching record is found.

### retreiving by batches

`Customer.all.each` in ruby instructs `ActiveRecord` to fetch the entire table from the db and each row into model and keep the entire array of objects in the memory

we have the following methods:

#### `find_each`

retrieves records in batches and then yields **each** one to the block.

```ruby
Customer.find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

the batch size of `find_each` is by default 1000

`find_each` also works on relations as long as they have no ordering

If an order is present in the receiver the behaviour depends on the flag `config.active_record.error_on_ignored_order`. If `true`, `ArgumentError` is raised, otherwise the order is ignored and a warning issued, which is the default. This can be overridden with the option `:error_on_ignore`

```ruby
Customer.where(weekly_subscriber: true).find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

##### options for `find_each`

- `:batch_size`
- `:start`: first id to take to sequence
- `:finish`: last id to take to sequence
- `:error_on_ignore`: Overrides the application config to specify if an error should be raised when an order is present in the relation.

#### `find_in_batches`

yields batches to the block as an array of models, instead of individually as in `find_each`.

```ruby
# Give add_customers an array of 1000 customers at a time.
Customer.find_in_batches do |customers|
  export.add_customers(customers)
end
```

the batch size of `find_in_batches` is by default 1000

`find_in_batches` also works on relations as long as they have no ordering

##### options for `find_in_batches`

same as [`find_each` options](#options-for-find_each)

## conditions

we must use the `where` method

### pure string conditions

```ruby
Book.where('title = "Intro To Ruby"')
```

NOTE: Building your own conditions as pure strings can leave you vulnerable to SQL injection exploits. For example, `Book.where("title LIKE '%#{params[:title]}%'")` is not safe.

### array conditions

```ruby
Book.where("title = ?", params[:title])

Book.where("title = ? AND out_of_print = ?", params[:title], false)

# we can also name the parameters to pass instead of ?
Book.where("created_at >= :start_date AND created_at <= :end_date",
  {start_date: params[:start_date], end_date: params[:end_date]})


# sanitize code which uses LIKE queries 
Book.where("title LIKE ?",
  Book.sanitize_sql_like(params[:title]) + "%")

```

### hash conditions

#### equality conditions

```ruby
Book.where(out_of_print: true)

Book.where('out_of_print' => true)
```

```sql
SELECT * FROM books WHERE (books.out_of_print = 1)
```

In the case of a `belongs_to` relationship, an association key can be used to specify the model if an Active Record object is used as the value. This method works with polymorphic relationships as well.

```ruby
author = Author.first
Book.where(author: author)
Author.joins(:books).where(books: { author: author })

```

#### range conditions

```ruby
Book.where(created_at: (Time.now.midnight - 1.day)..Time.now.midnight)
```

```sql
SELECT * FROM books WHERE (books.created_at BETWEEN '2008-12-21 00:00:00' AND '2008-12-22 00:00:00')
```

use beginless and endless ranges for greater than or less than queries

```ruby
Book.where(created_at: (Time.now.midnight - 1.day)..)
```

```sql
SELECT * FROM books WHERE books.created_at >= '2008-12-21 00:00:00'
```

#### subset conditions

```ruby
Customer.where(orders_count: [1,3,5])
```

```sql
SELECT * FROM customers WHERE (customers.orders_count IN (1,3,5))
```

### NOT conditions

```ruby
Customer.where.not(orders_count: [1,3,5])
```

```sql
SELECT * FROM customers WHERE (customers.orders_count NOT IN (1,3,5))
```

If a query has a hash condition with non-nil values on a nullable column, the records that have nil values on the nullable column won't be returned. For example:

```ruby
Customer.create!(nullable_contry: nil)
Customer.where.not(nullable_country: "UK")
=> []
# But
Customer.create!(nullable_contry: "UK")
Customer.where.not(nullable_country: nil)
=> [#<Customer id: 2, nullable_contry: "UK">]
```

### OR conditions

```ruby
Customer.where(last_name: 'Smith').or(Customer.where(orders_count: [1,3,5]))
```

```sql
SELECT * FROM customers WHERE (customers.last_name = 'Smith' OR customers.orders_count IN (1,3,5))
```

### AND conditions

- chaining `where` conditions

```ruby
Customer.where(last_name: 'Smith').where(orders_count: [1,3,5]))
```

```sql
SELECT * FROM customers WHERE customers.last_name = 'Smith' AND customers.orders_count IN (1,3,5)
```

- chaining `and`

```ruby
Customer.where(id: [1, 2]).and(Customer.where(id: [2, 3]))
```

```sql
SELECT * FROM customers WHERE (customers.id IN (1, 2) AND customers.id IN (2, 3))
```

## Ordering

To retrieve records from the database in a specific order, you can use the `order` method.

For example, if you're getting a set of records and want to order them in ascending order by the `created_at` field in your table:

```ruby
Book.order(:created_at)
# OR
Book.order("created_at")
```

You could specify ASC or DESC as well:

```ruby
Book.order(created_at: :desc)
# OR
Book.order(created_at: :asc)
# OR
Book.order("created_at DESC")
# OR
Book.order("created_at ASC")
```

Or ordering by multiple fields:

```ruby
Book.order(title: :asc, created_at: :desc)
# OR
Book.order(:title, created_at: :desc)
# OR
Book.order("title ASC, created_at DESC")
# OR
Book.order("title ASC", "created_at DESC")
```

If you want to call order multiple times, subsequent orders will be appended to the first:

```ruby
irb> Book.order("title ASC").order("created_at DESC")
```

```sql
SELECT * FROM books ORDER BY title ASC, created_at DESC
```

NOTE: In most database systems, on selecting fields with distinct from a result set using methods like `select`, `pluck` and `ids`; the order method will raise an `ActiveRecord::StatementInvalid` exception unless the field(s) used in order clause are included in the select list.

## selecting specific fields

by default `Model.find` performs the `SELECT *` operation

to specify fields we can use `Model.select`

```ruby
Book.select(:isbn, :out_of_print)
# OR
Book.select("isbn, out_of_print")
```

```sql
SELECT isbn, out_of_print FROM books
```

Be careful because this also means you're initializing a model object with **only** the fields that you've selected. If you attempt to access a field that is not in the initialized record you'll receive:

```shell
ActiveModel::MissingAttributeError: missing attribute: <attribute>
```

Where `<attribute>` is the attribute you asked for. The `id` method will not raise the `ActiveRecord::MissingAttributeError`, so just be careful when working with associations because they need the id method to function properly.

we can also add `.distinct` after the query to specify that we want only distinvct queries

```ruby
Customer.select(:last_name).distinct
```

```sql
SELECT DISTINCT last_name FROM customers
```

we can add a uniqueness constraint to a query and chain it with a `.distinct(false)` to remove the constraint

```ruby
# Returns unique last_names
query = Customer.select(:last_name).distinct

# Returns all last_names, even if there are duplicates
query.distinct(false)
```

## limit and offset

we can also add limit and offset to the query

```ruby
Customer.limit(5)
```

```sql
SELECT * FROM customers LIMIT 5
```

```ruby
Customer.limit(5).offset(30)
```

```sql
SELECT * FROM customers LIMIT 5 OFFSET 30
```

## group

the `.group` method applies a `GROUP BY` clause

```ruby
Order.select("created_at").group("created_at")
```

```sql
SELECT created_at
FROM orders
GROUP BY created_at
```

### counting groups

```ruby
Order.group(:status).count
#=> { "being_packed"=>7, "shipped"=>12 }
```

```sql
SELECT COUNT (*) AS count_all, status AS status
FROM orders
GROUP BY status
```

## having

`GROUP BY ... HAVING` in sql is represented by `Model.group().having()` in rails

```ruby
Order.select("created_at, sum(total) as total_price").group("created_at").having("sum(total) > ?", 200)
```

```sql
SELECT created_at as ordered_date, sum(total) as total_price
FROM orders
GROUP BY created_at
HAVING sum(total) > 200
```

```ruby
big_orders = Order.select("created_at, sum(total) as total_price")
                  .group("created_at")
                  .having("sum(total) > ?", 200)

big_orders[0].total_price
# Returns the total price for the first Order object
```

## overriding conditions

### unscope

```ruby
Book.where('id > 100').limit(20).order('id desc').unscope(:order)
```

```sql
SELECT * FROM books WHERE id > 100 LIMIT 20

-- Original query without `unscope`
SELECT * FROM books WHERE id > 100 ORDER BY id desc LIMIT 20
```

You can also unscope specific `where` clauses. For example, this will remove id condition from the where clause:

```ruby
Book.where(id: 10, out_of_print: false).unscope(where: :id)
# SELECT books.* FROM books WHERE out_of_print = 0
```

A relation which has used unscope will affect any relation into which it is merged:

```ruby
Book.order('id desc').merge(Book.unscope(:order))
# SELECT books.* FROM books
```

### only

we can also spqecify which scopes in a query are exected

```ruby
Book.where('id > 10').limit(20).order('id desc').only(:order, :where)
```

```sql
SELECT * FROM books WHERE id > 10 ORDER BY id DESC

-- Original query without `only`
SELECT * FROM books WHERE id > 10 ORDER BY id DESC LIMIT 20
```

### reselect

the `reselect` method overrides an already applied `select` scope

```ruby
Book.select(:title, :isbn).reselect(:created_at)
```

```sql
SELECT books.created_at FROM books
```

if instead of `reselect`, we use the `select` scope twice we get a select statement selecting all the columns specified in both the select scopes

```ruby
Book.select(:title, :isbn).select(:created_at)
```

```sql
SELECT books.title, books.isbn, books.created_at FROM books
```

### reorder

overrides the default scope's `order`

for ex:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order(year_published: :desc) }
end
```

and we run this

```ruby
Author.find(10).books
```

the sql queries are:

```sql
SELECT * FROM authors WHERE id = 10 LIMIT 1
SELECT * FROM books WHERE author_id = 10 ORDER BY year_published DESC
```

we can use `reorder` to specify a different order for `books`

```ruby
Author.find(10).books.reorder('year_published ASC')
```

```sql
SELECT * FROM authors WHERE id = 10 LIMIT 1
SELECT * FROM books WHERE author_id = 10 ORDER BY year_published ASC
```

### reverse order

this can reverse a defined `order` scope

```ruby
Book.where("author_id > 10").order(:year_published).reverse_order
```

```sql
SELECT * FROM books WHERE author_id > 10 ORDER BY year_published DESC
```

If no ordering clause is specified in the query, the `reverse_order` orders by the primary key in reverse order.

```ruby
Book.where("author_id > 10").reverse_order
```

The SQL that would be executed:

```sql
SELECT * FROM books WHERE author_id > 10 ORDER BY books.id DESC
```

The `reverse_order` method accepts **no** arguments.

### rewhere

overrides an existing `where`

```ruby
Book.where(out_of_print: true).rewhere(out_of_print: false)
```

```sql
SELECT * FROM books WHERE out_of_print = 0
```

if we instead chain `where` to the original query instead of `rewhere`, the queries will be ANDed together

```ruby
Book.where(out_of_print: true).where(out_of_print: false)
```

```sql
SELECT * FROM books WHERE out_of_print = 1 AND out_of_print = 0
```

## null relation

the `none` method returns an empty chainable relation with no records

Any subsequent conditions chained to the returned relation will continue generating empty relations. This is useful in scenarios where you need a chainable response to a method or a scope that could return zero results.

```ruby
Book.none # returns an empty Relation and fires no queries.
```

```ruby
# The highlighted_reviews method below is expected to always return a Relation.
Book.first.highlighted_reviews.average(:rating)
# => Returns average rating of a book

class Book
  # Returns reviews if there are at least 5,
  # else consider this as non-reviewed book
  def highlighted_reviews
    if reviews.count > 5
      reviews
    else
      Review.none # Does not meet minimum threshold yet
    end
  end
end
```

## readonly objects

Active Record provides the readonly method on a relation to explicitly disallow modification of any of the returned objects. Any attempt to alter a readonly record will not succeed, raising an `ActiveRecord::ReadOnlyRecord` exception.

```ruby
customer = Customer.readonly.first
customer.visits += 1
customer.save
```

As `customer` is explicitly set to be a `readonly` object, the above code will raise an `ActiveRecord::ReadOnlyRecord` exception when calling `customer.save` with an updated value of visits.

## locking records for update

### optimistic locking

allows multiple users to access the same record, and assumes minimum conflicts with the data, it is done by checking whether another process has made changes to the record since it was opened, if it has occured then `ActiveRecord::StaleObjectError` is thrown

to use optimistic locking, the table needs to have acolumn called `lock_version` of type integer, each time a record is updated the `lock_version` is incremented, if an update request is made with its `lock_version` value **lower** than the `lock_version` for that record currently in the db, the update request will fail with `ActiveRecord::StaleObjectError`

```ruby
c1 = Customer.find(1)
c2 = Customer.find(1)

c1.first_name = "Sandra"
c1.save

c2.first_name = "Michael"
c2.save # Raises an ActiveRecord::StaleObjectError
```

You're then responsible for dealing with the conflict by rescuing the exception and either rolling back, merging, or otherwise apply the business logic needed to resolve the conflict.

This behavior can be turned off by setting `ActiveRecord::Base.lock_optimistically = false`.

To override the name of the `lock_version` column, `ActiveRecord::Base` provides a class attribute called `locking_column`:

```ruby
class Customer < ApplicationRecord
  self.locking_column = :lock_customer_column
end
```

### pessimistic locking

Pessimistic locking uses a locking mechanism provided by the underlying database. Using `lock` when building a relation obtains an exclusive lock on the selected rows. Relations using `lock` are usually wrapped inside a `transaction` for preventing deadlock conditions.

For example:

```ruby
Book.transaction do
  book = Book.lock.first
  book.title = 'Algorithms, second edition'
  book.save!
end
```

The above session produces the following SQL for a MySQL backend:

```sql
SQL (0.2ms)   BEGIN
Book Load (0.3ms)   SELECT * FROM books LIMIT 1 FOR UPDATE
Book Update (0.4ms)   UPDATE books SET updated_at = '2009-02-07 18:05:56', title = 'Algorithms, second edition' WHERE id = 1
SQL (0.8ms)   COMMIT
```

You can also pass raw SQL to the `lock` method for allowing different types of locks. For example, MySQL has an expression called `LOCK IN SHARE MODE` where you can lock a record but still allow other queries to read it. To specify this expression just pass it in as the lock option:

```ruby
Book.transaction do
  book = Book.lock("LOCK IN SHARE MODE").find(1)
  book.increment!(:views)
end
```

NOTE: your database must support the raw SQL, that you pass in to the lock method.

If you already have an instance of your model, you can start a transaction and acquire the lock in one go using the following code:

```ruby
book = Book.first
book.with_lock do
  # This block is called within a transaction,
  # book is already locked.
  book.increment!(:views)
end
```

## joining tables

### `joins`

there are many ways to use the `joins` method

- raw sql

  You can just supply the raw SQL specifying the JOIN clause to joins:

  ```ruby
  Author.joins("INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE")
  ```

  This will result in the following SQL:

  ```sql
  SELECT authors.* FROM authors INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE
  ```

- `Array`/`Hash` of named association

  Performs JOINs on args. The given symbol(s) should match the name of the association(s).

  ```ruby
  User.joins(:posts)
  # SELECT "users".*
  #   FROM "users"
  #     INNER JOIN "posts" ON "posts"."user_id" = "users"."id"
  ```

  Multiple joins:

  ```ruby
  User.joins(:posts, :account)
  # SELECT "users".*
  #   FROM "users"
  #     INNER JOIN "posts" ON "posts"."user_id" = "users"."id"
  #     INNER JOIN "accounts" ON "accounts"."id" = "users"."account_id"
  ```

  Nested joins:

  ```ruby
  User.joins(posts: [:comments])
  # SELECT "users".*
  #   FROM "users"
  #     INNER JOIN "posts" ON "posts"."user_id" = "users"."id"
  #       INNER JOIN "comments" ON "comments"."post_id" = "posts"."id"
  ```

  Multiple Nested joins:

  ```ruby
  Author.joins(books: [{ reviews: { customer: :orders } }, :supplier] )
  # SELECT "authors".*
  #  FROM "authors"
  #    INNER JOIN "books" ON "books"."author_id" = "authors"."id"
  #      INNER JOIN "reviews" ON "reviews"."book_id" = "books"."id"
  #        INNER JOIN "customers" ON "customers"."id" = "reviews"."customer_id"
  #          INNER JOIN "orders" ON "orders"."customer_id" = "customers"."id"
  #      INNER JOIN "suppliers" ON "suppliers"."id" = "books"."suppliers_id"
  ```

- specifying conditions on the join tables
  
  You can specify conditions on the joined tables using the regular `Array` and `String` conditions. `Hash` conditions provide a special syntax for specifying conditions for the joined tables:

  ```ruby
  time_range = (Time.now.midnight - 1.day)..Time.now.midnight
  Customer.joins(:orders).where('orders.created_at' => time_range).distinct
  ```

  This will find all customers who have orders that were created yesterday, using a `BETWEEN` SQL expression to compare `created_at`.

  An alternative and cleaner syntax is to nest the hash conditions:

  ```ruby
  time_range = (Time.now.midnight - 1.day)..Time.now.midnight
  Customer.joins(:orders).where(orders: { created_at: time_range }).distinct
  ```

  For more advanced conditions or to reuse an existing named scope, `merge` may be used. First, let's add a new named scope to the `Order` model:

  ```ruby
  class Order < ApplicationRecord
    belongs_to :customer

    scope :created_in_time_range, ->(time_range) {
      where(created_at: time_range)
    }
  end
  ```

  Now we can use `merge` to merge in the `created_in_time_range` scope:

  ```ruby
  time_range = (Time.now.midnight - 1.day)..Time.now.midnight
  Customer.joins(:orders).merge(Order.created_in_time_range(time_range)).distinct
  ```

  This will find all customers who have orders that were created yesterday, again using a BETWEEN SQL expression.

### `left_outer_joins`/`left_joins`

select a set of records whether or not they have associated records

```ruby
Customer.left_outer_joins(:reviews).distinct.select('customers.*, COUNT(reviews.*) AS reviews_count').group('customers.id')
```

```sql
SELECT DISTINCT customers.*, COUNT(reviews.*) AS reviews_count
  FROM customers
  LEFT JOIN reviews
    ON reveiws.customer_id = customers.id
  GROUP BY customers.id
```

## eager loading associations

when we want to load associated objects for a specific object, we will have to deal with the N+1 query problem which means that for loading one object and N associated objects, we need to fire N+1 queries

```ruby
books = Book.limit(10)

books.each do |book|
  p book.author.last_name
end

# we need 11 queries to complete this operation
```

Active Record lets you specify in advance which queries will be needed for this association, using the following methods:

NOTW: `includes` works with **association names** while `references` needs the **actual table name**.

- `includes`
  With `includes`, Active Record ensures that all of the specified associations are loaded using the minimum possible number of queries.

  Revisiting the above case using the `includes` method, we could rewrite `Book.limit(10)` to eager load authors:

  ```ruby
  books = Book.includes(:author).limit(10)

  books.each do |book|
    puts book.author.last_name
  end
  ```

  The above code will execute just 2 queries, as opposed to the 11 queries from the original case:

  ```sql
  SELECT books.* FROM books LIMIT 10
  SELECT authors.* FROM authors
    WHERE authors.book_id IN (1,2,3,4,5,6,7,8,9,10)
  ```

  Eager Loading Multiple Associations:

  Array:

  ```ruby
  Customer.includes(:orders, :reviews)
  ```

  Nested Hash:

  ```ruby
  Customer.includes(orders: {books: [:supplier, :author]}).find(1)
  ```

  Specifying conditions:

  it is more recommended to use [joins](#joining-tables)

  ```ruby
  Author.includes(:books).where(books: { out_of_print: true })
  ```

  ```sql
    SELECT authors.id AS t0_r0, ... books.updated_at AS t1_r5 FROM authors LEFT OUTER JOIN books ON books.author_id = authors.id WHERE (books.out_of_print = 1)
  ```

  If there was no `where` condition, this would generate the normal set of two queries.

  NOTE: Using `where` like this will only work when you pass it a `Hash`. For SQL-fragments you need to use references to force joined tables

    ```ruby
    Author.includes(:books).where("books.out_of_print = true").references(:books)
    ```

    If, in the case of this `includes` query, there were no books for any authors, all the authors would still be loaded. By using `joins` (an INNER JOIN), the join conditions must match, otherwise no records will be returned.

  NOTE: If an association is eager loaded as part of a join, any fields from a custom select clause will not be present on the loaded models. This is because it is ambiguous whether they should appear on the parent record, or the child.

- `preload`

  With `preload`, Active Record loads each specified association using one query per association.

  NOTE: The `preload` method uses an `array`, `hash`, or a nested hash of array/hash in the same way as the `includes` method to load any number of associations with a single `Model.find` call. However, unlike the `includes` method, it is not possible to specify conditions for preloaded associations.

- `eager_load`
  With `eager_load`, Active Record loads all specified associations using a `LEFT OUTER JOIN`.

  NOTE: The `eager_load` method uses an `array`, `hash`, or a nested hash of array/hash in the same way as the `includes` method to load any number of associations with a single `Model.find` call. Also, like the `includes` method, you can specify conditions for eager loaded associations.

## scopes

Scoping allows you to specify commonly-used queries which can be referenced as method calls on the association objects or models. With these scopes, you can use every method previously covered such as `where`, `joins` and `includes`. All scope bodies should return an `ActiveRecord::Relation` or `nil` to allow for further methods (such as other scopes) to be called on it.

```ruby
class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
end

Book.out_of_print # returns out of print books

author = Author.first
author.books.out_of_print # returns all out of print books by `author`

# chaining scopes to other scopes

class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
  scope :out_of_print_and_expensive, -> { out_of_print.where("price > 500") }
end
```

NOTE: Even though we can define these as class methods and get most of the same functionality, A scope will always return an `ActiveRecord::Relation` object, even if the conditional evaluates to `false`, whereas a class method, will return `nil`. This can cause `NoMethodError` when chaining class methods with conditionals, if any of the conditionals return false.

### passing arguments

```ruby
class Book < ApplicationRecord
  scope :costs_more_than, ->(amount) { where("price > ?", amount) }
end

Book.costs_more_than(100.10)

author.books.costs_more_than(100.10)
```

### using conditionals

```ruby
class Order < ApplicationRecord
  scope :created_before, ->(time) { where("created_at < ?", time) if time.present? }
end
```

### default scope

when we wish for a scope to be applied to all queries of a model we can use `default_scope`

```ruby
class Book < ApplicationRecord
  default_scope { where(out_of_print: false) }
end
```

if you want more complex things to be done in the default scope we can define `self.default_scope` class method inside the model

```ruby
class Book < ApplicationRecord
  def self.default_scope
    # Should return an ActiveRecord::Relation.
  end
end
```

NOTE: The default_scope is also applied while creating/building a record when the scope arguments are given as a Hash. It is not applied while updating a record. E.g.:

  ```ruby
  class Book < ApplicationRecord
    default_scope { where(out_of_print: false) }
  end
  ```

  ```ruby
  irb> Book.new
  => #<Book id: nil, out_of_print: false>
  irb> Book.unscoped.new
  => #<Book id: nil, out_of_print: nil>
  ```

NOTE: Be aware that, when given in the Array format, default_scope query arguments cannot be converted to a Hash for default attribute assignment. E.g.:

  ```ruby
  class Book < ApplicationRecord
    default_scope { where("out_of_print = ?", false) }
  end

  irb> Book.new
  => #<Book id: nil, out_of_print: nil>
  ```

### merging of scopes

Just like `where` clauses, scopes are merged using `AND` conditions.

```ruby
class Book < ApplicationRecord
  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }

  scope :recent, -> { where('year_published >= ?', Date.current.year - 50 )}
  scope :old, -> { where('year_published < ?', Date.current.year - 50 )}
end

irb> Book.out_of_print.old
# SELECT books.* FROM books WHERE books.out_of_print = 'true' AND books.year_published < 1969
```

We can mix and match scope and where conditions and the final SQL will have all conditions joined with `AND`.

```ruby
irb> Book.in_print.where('price < 100')
# SELECT books.* FROM books WHERE books.out_of_print = 'false' AND books.price < 100
```

If we do want the last where clause to win then merge can be used.

```ruby
irb> Book.in_print.merge(Book.out_of_print)
# SELECT books.* FROM books WHERE books.out_of_print = true
```

One important caveat is that default_scope will be prepended in scope and where conditions.

```ruby
class Book < ApplicationRecord
  default_scope { where('year_published >= ?', Date.current.year - 50 )}

  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }
end

irb> Book.all
# SELECT books.* FROM books WHERE (year_published >= 1969)

irb> Book.in_print
# SELECT books.* FROM books WHERE (year_published >= 1969) AND books.out_of_print = false

irb> Book.where('price > 50')
# SELECT books.* FROM books WHERE (year_published >= 1969) AND (price > 50)
```

As you can see above the default_scope is being merged in both scope and where conditions.

### removing all scoping

If we wish to remove scoping for any reason we can use the unscoped method. This is especially useful if a `default_scope` is specified in the model and should not be applied for this particular query.

```ruby
Book.unscoped.load
```

This method removes all scoping and will do a normal query on the table.

```ruby
irb> Book.unscoped.all
# SELECT books.* FROM books

irb> Book.where(out_of_print: true).unscoped.all
# SELECT books.* FROM books
```

unscoped can also accept a block:

```ruby
irb> Book.unscoped { Book.out_of_print }
SELECT books.* FROM books WHERE books.out_of_print
```

## dynamic finders

For every field (also known as an attribute) you define in your table, Active Record provides a finder method. If you have a field called `first_name` on your `Customer` model for example, you get the instance method `find_by_first_name` for free from Active Record. If you also have a `locked` field on the Customer model, you also get `find_by_locked` method.

You can specify an exclamation point (!) on the end of the dynamic finders to get them to raise an `ActiveRecord::RecordNotFound` error if they do not return any records, like `Customer.find_by_first_name!("Ryan")`

If you want to find both by `first_name` and `orders_count`, you can chain these finders together by simply typing "and" between the fields. For example, `Customer.find_by_first_name_and_orders_count("Ryan", 5)`.

## enums

Declare an enum attribute where the values map to integers in the database, but can be queried by name. Example:

```ruby
class Conversation < ActiveRecord::Base
  enum :status, [ :active, :archived ]
end

# conversation.update! status: 0
conversation.active!
conversation.active? # => true
conversation.status  # => "active"

# conversation.update! status: 1
conversation.archived!
conversation.archived? # => true
conversation.status    # => "archived"

# conversation.status = 1
conversation.status = "archived"

conversation.status = nil
conversation.status.nil? # => true
conversation.status      # => nil
```

Scopes based on the allowed values of the enum field will be provided as well. With the above example:

```ruby
Conversation.active
Conversation.not_active
Conversation.archived
Conversation.not_archived
```

Of course, you can also query them directly if the scopes don't fit your needs:

```ruby
Conversation.where(status: [:active, :archived])
Conversation.where.not(status: :active)
```

Defining scopes can be disabled by setting :scopes to false.

```ruby
class Conversation < ActiveRecord::Base
  enum :status, [ :active, :archived ], scopes: false
end
```

You can set the default enum value by setting `:default`, like:

```ruby
class Conversation < ActiveRecord::Base
  enum :status, [ :active, :archived ], default: :active
end

conversation = Conversation.new
conversation.status # => "active"
```

It's possible to explicitly map the relation between attribute and database integer with a hash:

```ruby
class Conversation < ActiveRecord::Base
  enum :status, active: 0, archived: 1
end
```

Finally it's also possible to use a string column to persist the enumerated value. Note that this will likely lead to slower database queries:

```ruby
class Conversation < ActiveRecord::Base
  enum :status, active: "active", archived: "archived"
end
```

Note that when an array is used, the implicit mapping from the values to database integers is derived from the order the values appear in the array. In the example, `:active` is mapped to 0 as it's the first element, and `:archived` is mapped to 1. In general, the i-th element is mapped to i-1 in the database.

Therefore, once a value is added to the enum array, its position in the array must be maintained, and new values should only be added to the end of the array. To remove unused values, the explicit hash syntax should be used.

In rare circumstances you might need to access the mapping directly. The mappings are exposed through a class method with the pluralized attribute name, which return the mapping in a `ActiveSupport::HashWithIndifferentAccess` :

```ruby
Conversation.statuses[:active]    # => 0
Conversation.statuses["archived"] # => 1
```

Use that class method when you need to know the ordinal value of an enum. For example, you can use that when manually building SQL strings:

```ruby
Conversation.where("status <> ?", Conversation.statuses[:archived])
```

You can use the `:prefix` or `:suffix` options when you need to define multiple enums with same values. If the passed value is true, the methods are prefixed/suffixed with the name of the enum. It is also possible to supply a custom value:

```ruby
class Conversation < ActiveRecord::Base
  enum :status, [ :active, :archived ], suffix: true
  enum :comments_status, [ :active, :inactive ], prefix: :comments
end
```

With the above example, the bang and predicate methods along with the associated scopes are now prefixed and/or suffixed accordingly:

```ruby
conversation.active_status!
conversation.archived_status? # => false


conversation.comments_inactive!
conversation.comments_active? # => false
```

## method chaining

method chaining is defined as a method on an object which returns an instance of the same class so that another instance method can be applied on the object returned by the first method

You can chain methods in a statement when the previous method called returns an `ActiveRecord::Relation`, like `all`, `where`, and `joins`. Methods that return a single object have to be at the end of the statement.

When an Active Record method is called, the query is not immediately generated and sent to the database. The query is sent only when the data is actually needed. So each example below generates a single query.

### retrieving filtered data from multiple tables

```ruby
Customer
  .select('customers.id, customers.last_name, reviews.body')
  .joins(:reviews)
  .where('reviews.created_at > ?', 1.week.ago)
```

```sql
SELECT customers.id, customers.last_name, reviews.body
FROM customers
  INNER JOIN reviews
    ON reviews.customer_id = customers.id
  WHERE reviews.created_at > 'SOME-DATE'
```

### retrieving specific data from multiple tables

```ruby
Book
  .select('books.id, books.title, authors.first_name')
  .joins(:author)
  .find_by(title: 'Abstraction and Specification in Program Development')
```

```sql
SELECT books.id, books.title, authors.first_name
FROM books
  INNER JOIN authors
    ON books.author_id = authors.id
  WHERE books.title = 'Abstraction and Specification in Program Development'
  LIMIT 1
```

## find or build a new object

### `find_or_create_by`

checks whether a record with the specified attributes exists. If it doesn't, then `create` is called

```ruby
irb> Customer.find_or_create_by(first_name: 'Andy')
=> #<Customer id: 5, first_name: "Andy", last_name: nil, title: nil, visits: 0, orders_count: nil, lock_version: 0, created_at: "2019-01-17 07:06:45", updated_at: "2019-01-17 07:06:45">
```

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Andy') LIMIT 1
BEGIN
INSERT INTO customers (created_at, first_name, locked, orders_count, updated_at) VALUES ('2011-08-30 05:22:57', 'Andy', 1, NULL, '2011-08-30 05:22:57')
COMMIT
```

suppose we want to do something when a new object is being created we can do it in 2 ways

```ruby
# create_with
Customer.create_with(locked: false).find_or_create_by(first_name: 'Andy')

# block, the block is executed when the object is create
Customer.find_or_create_by(first_name: 'Andy') do |c|
  c.locked = false
end
```

### `find_or_create_by!`

### `find_or_initialize_by`

same as the above but calls `new` instead of `create`

## finding by SQL

If you'd like to use your own SQL to find records in a table you can use `find_by_sql`. The `find_by_sql` method will return an array of objects even if the underlying query returns just a single record. For example you could run this query:

```ruby
irb> Customer.find_by_sql("SELECT * FROM customers INNER JOIN orders ON customers.id = orders.customer_id ORDER BY customers.created_at desc")
=> [#<Customer id: 1, first_name: "Lucas" ...>, #<Customer id: 2, first_name: "Jan" ...>, ...]
```

`find_by_sql` provides you with a simple way of making custom calls to the database and retrieving instantiated objects.

### `select_all`

`find_by_sql` has a close relative called `connection.select_all`. `select_all` will retrieve objects from the database using custom SQL just like `find_by_sql` but will not instantiate them. This method will return an instance of `ActiveRecord::Result` class and calling `to_a` on this object would return you an array of hashes where each hash indicates a record.

```ruby
irb> Customer.connection.select_all("SELECT first_name, created_at FROM customers WHERE id = '1'").to_a
=> [{"first_name"=>"Rafael", "created_at"=>"2012-11-10 23:23:45.281189"}, {"first_name"=>"Eileen", "created_at"=>"2013-12-09 11:22:35.221282"}]
```

### `pluck`

can be used to query single or multiple columns in the table for the model. It accepts a list of column names as an argument and returns an array of values of the specified columns with the corresponding data type.

```ruby
irb> Book.where(out_of_print: true).pluck(:id)
SELECT id FROM books WHERE out_of_print = true
=> [1, 2, 3]

irb> Order.distinct.pluck(:status)
SELECT DISTINCT status FROM orders
=> ["shipped", "being_packed", "cancelled"]

irb> Customer.pluck(:id, :first_name)
SELECT customers.id, customers.first_name FROM customers
=> [[1, "David"], [2, "Fran"], [3, "Jose"]]
```

pluck makes it possible to replace code like:

```ruby
Customer.select(:id).map { |c| c.id }
# or
Customer.select(:id).map(&:id)
# or
Customer.select(:id, :first_name).map { |c| [c.id, c.first_name] }

# with:

Customer.pluck(:id)
# or
Customer.pluck(:id, :first_name)
```

Unlike `select`, `pluck` directly converts a database result into a Ruby `Array`, without constructing `ActiveRecord` objects. This can mean better performance for a large or frequently-run query. However, any model method overrides will not be available. For example:

```ruby
class Customer < ApplicationRecord
  def name
    "I am #{first_name}"
  end
end

irb> Customer.select(:first_name).map &:name
=> ["I am David", "I am Jeremy", "I am Jose"]

irb> Customer.pluck(:first_name)
=> ["David", "Jeremy", "Jose"]
```

You are not limited to querying fields from a single table, you can query multiple tables as well.

```ruby
irb> Order.joins(:customer, :books).pluck("orders.created_at, customers.email, books.title")
```

Furthermore, unlike `select` and other Relation scopes, `pluck` triggers an immediate query, and thus cannot be chained with any further scopes, although it can work with scopes already constructed earlier:

```ruby
irb> Customer.pluck(:first_name).limit(1)
# NoMethodError: undefined method `limit' for #<Array:0x007ff34d3ad6d8>

irb> Customer.limit(1).pluck(:first_name)
=> ["David"]
```

You should also know that using `pluck` will trigger eager loading if the relation object contains include values, even if the eager loading is not necessary for the query. For example:

```ruby
irb> assoc = Customer.includes(:reviews)
irb> assoc.pluck(:id)
# SELECT "customers"."id" FROM "customers" LEFT OUTER JOIN "reviews" ON "reviews"."id" = "customers"."review_id"
```

One way to avoid this is to unscope the includes:

```ruby
irb> assoc.unscope(:includes).pluck(:id)
```

### `ids`

can be used to pluck all ids

```ruby
irb> Customer.ids
SELECT id FROM customers

class Customer < ApplicationRecord
  self.primary_key = "customer_id"
end

irb> Customer.ids
SELECT customer_id FROM customers
```

## existence of objects

If you simply want to check for the existence of the object there's a method called `exists?`. This method will query the database using the same query as find, but instead of returning an object or collection of objects it will return either `true` or `false`.

```ruby
Customer.exists?(1)
```

The `exists?` method also takes multiple values, but the catch is that it will return `true` if **any one** of those records exists.

```ruby
Customer.exists?(id: [1,2,3])
# or
Customer.exists?(first_name: ['Jane', 'Sergei'])
```

It's even possible to use `exists?` without any arguments on a model or a relation.

```ruby
Customer.where(first_name: 'Ryan').exists?
```

The above returns `true` if there is at least one customer with the `first_name: 'Ryan'` and false otherwise.

```ruby
Customer.exists?
```

The above returns false if the customers table is empty and true otherwise.

You can also use `any?` and `many?` to check for existence on a model or relation. many? will use SQL count to determine if the item exists.

```ruby
# via a model
Order.any?
# => SELECT 1 FROM orders LIMIT 1
Order.many?
# => SELECT COUNT(*) FROM (SELECT 1 FROM orders LIMIT 2)

# via a named scope
Order.shipped.any?
# => SELECT 1 FROM orders WHERE orders.status = 0 LIMIT 1
Order.shipped.many?
# => SELECT COUNT(*) FROM (SELECT 1 FROM orders WHERE orders.status = 0 LIMIT 2)

# via a relation
Book.where(out_of_print: true).any?
Book.where(out_of_print: true).many?

# via an association
Customer.first.orders.any?
Customer.first.orders.many?
```

## calculations

### `count`

```ruby
irb> Customer.count
SELECT COUNT(*) FROM customers
```

Or on a relation:

```ruby
irb> Customer.where(first_name: 'Ryan').count
SELECT COUNT(*) FROM customers WHERE (first_name = 'Ryan')
```

You can also use various finder methods on a relation for performing complex calculations:

```ruby
irb> Customer.includes("orders").where(first_name: 'Ryan', orders: { status: 'shipped' }).count
```

Which will execute:

```sql
SELECT COUNT(DISTINCT customers.id) FROM customers
  LEFT OUTER JOIN orders ON orders.customer_id = customers.id
  WHERE (customers.first_name = 'Ryan' AND orders.status = 0)
```

assuming that Order has `enum status: [ :shipped, :being_packed, :cancelled ]`.

If you want to be more specific and find all the customers with a title present in the database you can use `Customer.count(:title)`.

## `average`

If you want to see the average of a certain number in one of your tables you can call the average method on the class that relates to the table. This method call will look something like this:

```ruby
Order.average("subtotal")
```

This will return a number (possibly a floating-point number such as 3.14159265) representing the average value in the field.

## `minimum`

If you want to find the minimum value of a field in your table you can call the minimum method on the class that relates to the table. This method call will look something like this:

```ruby
Order.minimum("subtotal")
```

## `maximum`

If you want to find the maximum value of a field in your table you can call the maximum method on the class that relates to the table. This method call will look something like this:

```ruby
Order.maximum("subtotal")
```

## `sum`

If you want to find the sum of a field for all records in your table you can call the sum method on the class that relates to the table. This method call will look something like this:

```ruby
Order.sum("subtotal")
```

## `EXPLAIN` query

```ruby
Customer.where(id: 1).joins(:orders).explain
```

Eager loading may trigger more than one query under the hood, and some queries may need the results of previous ones. Because of that, explain actually executes the query, and then asks for the query plans.
