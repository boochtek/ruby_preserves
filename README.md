Preserves
=========

Preserves is a minimalist ORM (object-relational mapper) for Ruby, using the
Repository and Data Mapper patterns.

We're trying to answer these questions:

* How simple can we make an ORM that is still useful?
* Developers have to know SQL anyway, so why try to hide the SQL from them?
  * Is the complexity of a typical ORM really better than the complexity of SQL?
* ORMs are a leaky abstraction. What if we made it so leaky that it doesn't matter?

This ORM is based on a few strong opinions:

* The Data Mapper pattern is generally better than the Active Record pattern.
  * Unless you're just writing a CRUD front-end, with little interesting behavior.
* Declaring attributes in the domain model is better than hiding them elsewhere.
  * Declaring relationships in one place and attributes in another is true madness.
* NoSQL as a main data store is usually misguided.
  * PostgreSQL can do just about anything you need, using SQL.
* Projects are unlikely to need to abstract SQL to allow them to use different RDBMSes.
  * Developer workstations are fast enough to run "full" RDBMSes.
  * If you're not using "interesting" features, then you're probably using "standard" SQL.

The Data Mapper pattern provides several advantages:

* Domain objects don't have to know anything about the database or its schema.
  * Instead, the mapper knows about the domain objects and the database.
    * DB schema can change without having to change to domain objects; only the mapper changes.
* The domain objects are self-contained.
  * Don't have to look elsewhere to understand everything a class contains.
* Better meets the Single Responsibility Principle (SRP).
  * Domain model classes handle business logic.
  * Repository classes handle persistence.
  * Mapper classes handle mapping database fields to object attributes.


Installation
------------

Add this line to your application's Gemfile:

    gem 'preserves'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install preserves


Example Usage
-------------

First, create your model class:

~~~ ruby
class User
  include Virtus.model
  attribute :id, String
  attribute :name, String
  attribute :age, Integer
end
~~~

[Virtus] isn't strictly necessary, but it lets us define our model
attributes easily and makes it easier to define the mappings.
The repository might look something like this:

~~~ ruby
Preserves.data_store = Preserves::PostgreSQL("my_database")

UserRepository = Preserves.repository(for: User) do

  # We'll likely provide `insert`, but this gives an idea of how minimal we'll be to start off.
  def insert(user)
    result = query("INSERT INTO 'users' (username, name, age) VALUES (?, ?, ?)",
                   user.id, user.name, user.age)
    raise "Could not insert User #{user.id} into database" unless result.rows == 1
  end

  def older_than(age)
    select("SELECT *, username AS id FROM 'users' WHERE age > ? ORDER BY ?", age, :name)
  end

  def with_id(id)
    select("SELECT *, username AS id FROM 'users' WHERE username = ?", id)
  end
end
~~~

Now we can create model objects and use the repository to save them to and
retrieve them from the database:

~~~ ruby
craig = User.new(id: "booch", name: "Craig", age: 42)
UserRepository.insert(craig)
users_over_40 = UserRepository.older_than(40)   # Returns an Enumerable set of User objects.
beth = UserRepository.with_id("beth").one       # Returns a single User object or nil.
~~~


API Summary
-----------

NOTE: This project is in very early exploratory stages. The API **will** change.


### Repository ###

Most of the API you'll use will be in the your repository object.
The mixin provides the following methods:

~~~ ruby
query(sql_string)           # Runs SQL and returns a Preserves::SQL::Result.
select(sql_select_string)   # Runs SQL and returns a Preserves::Selection.
~~~

### Preserves::SQL::Result ###

~~~ ruby
result.rows     # Number of rows that were affected by the SQL query.
result.data     # Array of Hashes, for any data returned by the query.
~~~


### Preserves::Selection ###

The Selection is an Enumerable, representing the results of a SELECT query, mapped to domain objects.
Most of your interactions with Selections will be through the Enumberable interface.

~~~ ruby
selection.one   # Returns a single domain object. Returns nil if no results; raises an exception if more than 1 result. 
selection.one!  # Same as `one`, but raises an exception instead of returning nil, if the query returns no results.
selection.each { |user| puts user.name }    # Iterate through the set of domain objects.
~~~


Contributing
------------

1. Fork the [project repo].
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Make sure tests pass (`rspec` or `rake spec`).
4. Commit your changes (`git commit -am 'Add some feature'`).
5. Push to the branch (`git push origin my-new-feature`).
6. Create a new [pull request].


[project repo]: https://github.com/boochtek/ruby_preserves/fork
[pull request]: https://github.com/boochtek/ruby_preserves/pulls
[Virtus]: https://github.com/solnic/virtus#readme
