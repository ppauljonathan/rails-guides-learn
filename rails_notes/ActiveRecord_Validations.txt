# Validations
Validations are used to ensure that only valid data is saved in your db
they are db agnostic, and therefore are easy to use, test, and maintain

- model-level
- db-level
- client-level
- controller-level

a model in rails is made using a class which is a subclass of ApplicationRecord, which inherits form ActiveRecord:: Base

class Person < ApplicationRecord
end

# to add validations, we add validations when defining the Person model

class Person < ApplicationRecord
  validates :name, presence: true
  validates :age, numericality: { greater_than_or_equal_to: 0 }
end

p = Person.new

the object p viz an instance of Person is currently present in the scope of the program but has not yet been stored in the db

to do this, rails first uses p.new_record? method to find whether the object p is already present in the database or not, then when p.save is called, it checks the validations and if they pass, then saves the object to the db

p.save returns false if the validations fail
p.save! throws an error if the validations fail
* this is true for all the below methods, the bang methods throw error while the non-bang methods return false if validations fail

The following methods trigger validations, and will save the object to the database only if the object is valid:

    create
    create!
    save
    save!
    update
    update!

The following methods skip validations, and will save the object to the database regardless of its validity. They should be used with caution.

    decrement!
    decrement_counter
    increment!
    increment_counter
    insert
    insert!
    insert_all
    insert_all!
    toggle!
    touch
    touch_all
    update_all
    update_attribute
    update_column
    update_columns
    update_counters
    upsert
    upsert_all

Note that save also has the ability to skip validations if passed validate:
false as an argument. This technique should be used with caution.

    save(validate: false)


the preamble methods .valid? and .invalid? run the validations on the object

when an object of Person is created the validations are not run until rails attempts to save the object in the db at which point, validations are run and any errors are put in the instance variable, errors for p, which is a collection of errors

irb> p = Person.new
=> #<Person id: nil, name: nil>
irb> p.errors.size
=> 0

irb> p.valid?
=> false
irb> p.errors.objects.first.full_message
=> "Name can't be blank"

irb> p = Person.create
=> #<Person id: nil, name: nil>
irb> p.errors.objects.first.full_message
=> "Name can't be blank"

irb> p.save
=> false

irb> p.save!
ActiveRecord::RecordInvalid: Validation failed: Name can't be blank

irb> Person.create!
ActiveRecord::RecordInvalid: Validation failed: Name can't be blank


the errors are not added till the object is attempted to be stored in the db and fails validation
irb> Person.new.errors[:name].any?
=> false
irb> Person.create.errors[:name].any?
=> true

# validation helpers
- acceptance
This method validates that a checkbox on the user interface was checked when a form was submitted. This is typically used when the user needs to agree to your application's terms of service, confirm that some text is read, or any similar concept.

class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true
end

custom messages can be passed using the :messages option, default: 'must be accepted'

class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { message: 'Must be abided' }
end

the :accept option detemines which values will be considered as accepted

class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { accept: 'yes' }
  validates :eula, acceptance: { accept: ['TRUE', 'accepted'] }
end

we also can pass the :reject option
class Employee < ApplicationRecord
  validates :training, acceptance: { reject: 'no' } # accepts all things except 'no'
end

- validates_associated
used when model has associations with another model and the other model also needs validation,
validates_associated runs validation (.valid?) on each of the associated objects

IMP_NOTE: don't use validates_associated on both models of the association otherwise they will create an infinite loop
default error message: "is invalid"

- confirmation
two text fields should receive same input like in email or password

class Person < ApplicationRecord
  validates :email, confirmation: true
end

this creates a virual attribute :email_confirmation

this can be used in templates like so:
<%= text_field :person, :email %>
<%= text_field :person, :email_confirmation %>

the check is only performed when :email_confirmation is not nil, to require the confirmation, we need to make sure that the :email_confirmation attribute is also not nil
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true
end

there is also a case sensitive option, defults to true
class Person < ApplicationRecord
  validates :email, confirmation: { case_sensitive: false }
end
default error message: 'doesn't match confirmation'

- comparision
creates validation b/w 2 comparable values, options must be provided, each option takes a value, symbol or proc
class Promotion < ApplicationRecord
  validates :start_date, comparison: { greater_than: :end_date }
end

These options are all supported:

    :greater_than - Specifies the value must be greater than the supplied value. The default error message for this option is "must be greater than %{count}".

    :greater_than_or_equal_to - Specifies the value must be greater than or equal to the supplied value. The default error message for this option is "must be greater than or equal to %{count}".

    :equal_to - Specifies the value must be equal to the supplied value. The default error message for this option is "must be equal to %{count}".

    :less_than - Specifies the value must be less than the supplied value. The default error message for this option is "must be less than %{count}".

    :less_than_or_equal_to - Specifies the value must be less than or equal to the supplied value. The default error message for this option is "must be less than or equal to %{count}".

    :other_than - Specifies the value must be other than the supplied value. The default error message for this option is "must be other than %{count}".


- exclusion (opp of inclusion)
validates if the value is not in the given set
class Account < ApplicationRecord
  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value} is reserved." }
end

:in is also aliased as :within
defult error message: 'is reserved'

- format
validates if value matches regex given in :with option
class Product < ApplicationRecord
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "only allows letters" }
end

also validates if value does not match regex given in :without option
default error message: 'is invalid'

- inclusion (opp of exclusion)
validates if value is in the given set
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }
end

:in is also aliased as :within
defult error message: 'is not included in the list'

- length
validates length of attribute
class Person < ApplicationRecord
  validates :name, length: { minimum: 2, too_long: 'too long' }
  validates :bio, length: { maximum: 500, too_short: 'too short' }
  validates :password, length: { in/within: 6..20 }
  validates :registration_number, length: { is: 6, wrong_length: 'wrong length' }
end

- numericality
only numeric values allowed
class Player < ApplicationRecord
  validates :points, numericality: true
  validates :games_played, numericality: { only_integer: true }
end

if :only_integer is passed, then float values are not allowed

Besides :only_integer, this helper also accepts the following options to add constraints to acceptable values:

    :greater_than - Specifies the value must be greater than the supplied value. The default error message for this option is "must be greater than %{count}".

    :greater_than_or_equal_to - Specifies the value must be greater than or equal to the supplied value. The default error message for this option is "must be greater than or equal to %{count}".

    :equal_to - Specifies the value must be equal to the supplied value. The default error message for this option is "must be equal to %{count}".

    :less_than - Specifies the value must be less than the supplied value. The default error message for this option is "must be less than %{count}".

    :less_than_or_equal_to - Specifies the value must be less than or equal to the supplied value. The default error message for this option is "must be less than or equal to %{count}".

    :other_than - Specifies the value must be other than the supplied value. The default error message for this option is "must be other than %{count}".

    :in - Specifies the value must be in the supplied range. The default error message for this option is "must be in %{count}".

    :odd - Specifies the value must be an odd number if set to true. The default error message for this option is "must be odd".

    :even - Specifies the value must be an even number if set to true. The default error message for this option is "must be even".

By default, numericality doesn't allow nil values. You can use allow_nil: true option to permit it.
The default error message when no options are specified is "is not a number".

- presence (opp of absence)
This helper validates that the specified attributes are not empty. It uses the blank? method to check if the value is either nil or a blank string, that is, a string that is either empty or consists of whitespace.

class Person < ApplicationRecord
  validates :name, :login, :email, presence: true
end

to verify whether an association is present, we must also verify the presence of the associated object, and not just that the foreign key exists

class Supplier < ApplicationRecord
  has_one :account
  validates :account, presence: true
end

In order to validate associated records whose presence is required, you must specify the :inverse_of option for the association:
    If you want to ensure that the association it is both present and valid, you also need to use validates_associated.

class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end

 If you validate the presence of an object associated via a has_one or has_many relationship, it will check that the object is neither blank? nor marked_for_destruction?.

 now
  false.blank? #=> true

so to check a boolean value, we need to use :inclusion/:exclusion
validates :boolean_field_name, inclusion: [true, false]
validates :boolean_field_name, exclusion: [nil]
default message: 'must not be blank'

- absence (opp of presence)
This helper validates that the specified attributes are absent. It uses the present? method to check if the value is not either nil or a blank string, that is, a string that is either empty or consists of whitespace.

class Person < ApplicationRecord
  validates :name, :login, :email, absence: true
end

If you want to be sure that an association is absent, you'll need to test whether the associated object itself is absent, and not the foreign key used to map the association.

class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, absence: true
end

In order to validate associated records whose absence is required, you must specify the :inverse_of option for the association:

class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end

If you validate the absence of an object associated via a has_one or has_many relationship, it will check that the object is neither present? nor marked_for_destruction?.

Since false.present? is false, if you want to validate the absence of a boolean field you should use validates :field_name, exclusion: { in: [true, false] }.

The default error message is "must be blank".

- uniquness
checks unique constraint, since this does not create unique constraint on db, if our data spans different dbs, we will face a problem, so we must also uniquely index the column in the db
class Account < ApplicationRecord
  validates :email, uniqueness: true
end

we can also check uniqueness in the scope of another column, i.e the pair of data must be unique in the table, for the reason given above, we must also define uniqueness constraints on both these columns in db
class Holiday < ApplicationRecord
  validates :name, uniqueness: { scope: :year,
    message: "should happen once per year" }
end

There is also a :case_sensitive option that you can use to define whether the uniqueness constraint will be case sensitive, case insensitive, or respects default database collation. This option defaults to respects default database collation.

class Person < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
end

Note that some databases are configured to perform case-insensitive searches anyway.

The default error message is "has already been taken".

- validates_with
passes validation logic to a separate class

class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if record.first_name == "Evil"
      record.errors.add :base, "This person is evil"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator
end

errors added to record.errors[:base] are generic errors for the whole record, and not just for a particular attribute, to do that we must add to record.errors[:attr_name]

Like all other validations, validates_with takes the :if, :unless and :on options. If you pass any other options, it will send those options to the validator class as options:

class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if options[:fields].any? { |field| record.send(field) == "Evil" }
      record.errors.add :base, "This person is evil"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator, fields: [:first_name, :last_name]
end


IMP_NOTE: the validator will be initialized [[only once]] for the whole application life cycle, and not on each validation run, so be careful about using instance variables inside it.

we can pass an object to the instance of validator class, we can also make new instances if we want to use instance variables

class Person < ApplicationRecord
  validate do |person|
    GoodnessValidator.new(person).validate
  end
end

class GoodnessValidator
  def initialize(person)
    @person = person
  end

  def validate
    if some_complex_condition_involving_ivars_and_private_methods?
      @person.errors.add :base, "This person is evil"
    end
  end

  # ...
end


- validates_each
validates attributes against given block, does not have a predefined validation function

class Person < ApplicationRecord
  validates_each :name, :surname do |record, attr, value|
    record.errors.add(attr, 'must start with upper case') if value =~ /\A[[:lower:]]/
  end
end

# common validation options
- allow_nil
The :allow_nil option skips the validation when the value being validated is nil.

class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }, allow_nil: true
end

- allow blank
The :allow_blank option is similar to the :allow_nil option. This option will let validation pass if the attribute's value is blank?, like nil or an empty string for example.

class Topic < ApplicationRecord
  validates :title, length: { is: 5 }, allow_blank: true
end

irb> Topic.create(title: "").valid?
=> true
irb> Topic.create(title: nil).valid?
=> true

- message
the :message option allows you to specify what error message to be displayed, when not used, ActiveRecord uses the default message, the error message can be specified using a Proc or String

A String :message value can optionally contain any/all of %{value}, %{attribute}, and %{model} which will be dynamically replaced when validation fails. This replacement is done using the I18n gem, and the placeholders must match exactly, no spaces are allowed.

## this interpolation has %{}, not #{}

A Proc :message value is given two arguments: the object being validated, and a hash with :model, :attribute, and :value key-value pairs.

class Person < ApplicationRecord
  # Hard-coded message

  validates :name, presence: { message: "must be given please" }

  # Message with dynamic attribute value. %{value} will be replaced
  # with the actual value of the attribute. %{attribute} and %{model}
  # are also available.

  validates :age, numericality: { message: "%{value} seems wrong" }

  # Proc
  validates :username,
    uniqueness: {
      # object = person object being validated
      # data = { model: "Person", attribute: "Username", value: <username> }
      message: ->(object, data) do
        "Hey #{object.name}, #{data[:value]} is already taken."
      end
    }
end

- on
lets you specify when the validation should occur

class Person < ApplicationRecord
  # it will be possible to update email with a duplicated value
  validates :email, uniqueness: true, on: :create

  # it will be possible to create the record with a non-numerical age
  validates :age, numericality: true, on: :update

  # the default (validates on both create and update)
  validates :name, presence: true
end



You can also use on: to define custom contexts. Custom contexts need to be triggered explicitly by passing the name of the context to valid?, invalid?, or save.

class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
end

irb> person = Person.new(age: 'thirty-three')
irb> person.valid?
=> true
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["has already been taken"], :age=>["is not a number"]}

person.valid?(:account_setup) executes both the validations without saving the model. person.save(context: :account_setup) validates person in the account_setup context before saving.

When triggered by an explicit context, validations are run for that context, as well as any validations without a context.

class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
  validates :name, presence: true
end

irb> person = Person.new
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["has already been taken"], :age=>["is not a number"], :name=>["can't be blank"]}

# Strict Validations
always throw error when invalid regardless of bang methods

class Person < ApplicationRecord
  validates :name, presence: { strict: true }
end

irb> Person.new.valid?
ActiveModel::StrictValidationFailed: Name can't be blank


we can also pass custom error to :strict

class Person < ApplicationRecord
  validates :token, presence: true, uniqueness: true, strict: TokenGenerationException
end

irb> Person.new.valid?
TokenGenerationException: Token can't be blank

# conditional validation
when we want to validate on some previous unrelated conditions, we use :if, :unless predicates to check for conditions

- using a symbol with predicates
class Order < ApplicationRecord
  validates :card_number, presence: true, if: :paid_with_card?

  def paid_with_card?
    payment_type == "card"
  end
end

- using a Proc
class Account < ApplicationRecord
  validates :password, confirmation: true,
    unless: Proc.new { |a| a.password.blank? }
end

note that we can use labmda here as well

- grouping conditional validations (different from grouping conditionals)
class User < ApplicationRecord
  with_options if: :is_admin? do |admin|
    admin.validates :password, length: { minimum: 10 }
    admin.validates :email, presence: true
  end
end

here the with_options method performs the validations inside the block if the :is_admin condition

- grouping conditionals (different from grouping conditional validations)
we can use an Array of conditionals in an :if/:unless option, we can also add :if and :unless to the same validation

The validation only runs when all the :if conditions and none of the :unless conditions are evaluated to true.

# performing custom validations

to make a custom validator, you must inherit the custom validator class from ActiveModel::Validator, ActiveModel::Validator expects a validate(record) method to be implemented in the class (with the record to be validated passed as the argument), the custom validator is called using the validates_with method

class MyValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.start_with? 'X'
      record.errors.add :name, "Need a name starting with X please!"
    end
  end
end

class Person
  include ActiveModel::Validations
  validates_with MyValidator
end

this can only be run for the full record and the full record is passed into the validator

if we want to check only one attribute of a record, we can inherit from ActiveModel::EachValidator, which expects the custom class to implement a validate_each(record, attribute, value), These arguments correspond to the instance, the attribute to be validated, and the value of the attribute in the passed instance.

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors.add attribute, (options[:message] || "is not an email")
    end
  end
end

class Person < ApplicationRecord
  validates :email, presence: true, email: true
end

we can combine standard validators with our custom validators

# custom validation methods
You can also create methods that verify the state of your models and add errors to the errors collection when they are invalid. You must then register these methods by using the validate class method, passing in the symbols for the validation methods' names.

You can pass more than one symbol for each class method and the respective validations will be run in the same order as they were registered.

The valid? method will verify that the errors collection is empty, so your custom validation methods should add errors to it when you wish validation to fail:

class Invoice < ApplicationRecord
  validate :expiration_date_cannot_be_in_the_past,
    :discount_cannot_be_greater_than_total_value

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "can't be in the past")
    end
  end

  def discount_cannot_be_greater_than_total_value
    if discount > total_value
      errors.add(:discount, "can't be greater than total value")
    end
  end
end

By default, such validations will run every time you call valid? or save the object. But it is also possible to control when to run these custom validations by giving an :on option to the validate method, with either: :create or :update.

class Invoice < ApplicationRecord
  validate :active_customer, on: :create

  def active_customer
    errors.add(:customer_id, "is not active") unless customer.active?
  end
end

# Working with validation errors

an ApplicationRecord inheriting class 
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

we can create an object of this class
p = Person.new

p.valid? #=> false

the full error object of type ActiveModel::Errors
p.errors #=> ["Name can't be blank", "Name is too short (minimum is 3 characters)"]

irb> person = Person.new(name: "John Doe")
irb> person.valid?
=> true
irb> person.errors.full_messages
=> []


errors[:attr_name] is used to check the errors for a specific attribute
irb> person = Person.new(name: "JD")
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["is too short (minimum is 3 characters)"]
irb> person.errors[:age]
=> []


irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name)
=> [ ... ] # all errors for :name attribute

irb> person.errors.where(:name, :too_short)
=> [ ... ] # :too_short errors for :name attribute

You can read various information from these error objects:

irb> error = person.errors.where(:name).last

irb> error.attribute
=> :name
irb> error.type
=> :too_short
irb> error.options[:count]
=> 3

You can also generate the error message:

irb> error.message
=> "is too short (minimum is 3 characters)"
irb> error.full_message
=> "Name is too short (minimum is 3 characters)"

The full_message method generates a more user-friendly message, with the capitalized attribute name prepended.


The add method creates the error object by taking the attribute, the error type and additional options hash. This is useful for writing your own validator.

class Person < ApplicationRecord
  validate do |person|
    errors.add :name, :too_plain, message: "is not cool enough"
  end
end

irb> person = Person.create
irb> person.errors.where(:name).first.type
=> :too_plain

irb> person.errors.where(:name).first.full_message
=> "Name is not cool enough"

You can add errors that are related to the object's state as a whole, instead of being related to a specific attribute. You can add errors to :base when you want to say that the object is invalid, no matter the values of its attributes.

class Person < ApplicationRecord
  validate do |person|
    errors.add :base, :invalid, message: "This person is invalid because ..."
  end
end

irb> person = Person.create
irb> person.errors.where(:base).first.full_message
=> "This person is invalid because ..."

The clear method is used when you intentionally want to clear the errors collection. Of course, calling errors.clear upon an invalid object won't actually make it valid: the errors collection will now be empty, but the next time you call valid? or any method that tries to save this object to the database, the validations will run again. If any of the validations fail, the errors collection will be filled again.

class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.empty?
=> false

irb> person.errors.clear
irb> person.errors.empty?
=> true

irb> person.save
=> false

irb> person.errors.empty?
=> false

The size method returns the total number of errors for the object.

class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.size
=> 2

irb> person = Person.new(name: "Andrea", email: "andrea@example.com")
irb> person.valid?
=> true
irb> person.errors.size
=> 0




