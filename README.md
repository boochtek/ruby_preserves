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

It's been pointed out that Preserves might not in fact even be an ORM, because it doesn't have a complete model of the relations between objects.


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

First, create your domain model class. You can use a Struct, an
OStruct, a Virtus model, or a plain old Ruby object (PORO) class.
We'll use a Struct in the examples, so we can initialize the fields easily.

~~~ ruby
User = Struct.new(:id, :name, :age) do
end
~~~

Next, configure the Preserves data store.

~~~ ruby
Preserves.data_store = Preserves::PostgreSQL("my_database")
~~~

Then create a repository linked to the domain model class.
By default, all attributes will be assumed to be Strings.
For other attribute types, you'll need to supply the mapping.
(We'll have some default mappings determined from the DB or model later.)
Your repository should then define methods to access model objects
in the database. (These will mostly be like ActiveRecord scopes.)

~~~ ruby
UserRepository = Preserves.repository(model: User) do
  mapping do
    map id: 'username'  # The database field named 'username' corresponds to the 'id' attribute in the model.
    map :age, Integer   # The 'age' field should be mapped to an Integer in the model.
  end

  # We'll likely provide `insert`, but this gives an idea of how minimal we'll be to start off.
  def insert(user)
    result = query("INSERT INTO 'users' (username, name, age) VALUES ($1, $2, $3)",
                   user.id, user.name, user.age)
    raise "Could not insert User #{user.id} into database" unless result.size == 1
  end

  def older_than(age)
    map(select("SELECT *, username AS id FROM 'users' WHERE age > $1 ORDER BY $2", age, :name))
  end

  def with_id(id)
    map(select("SELECT *, username AS id FROM 'users' WHERE username = $1", id))
  end
end
~~~

Now we can create model objects and use the repository to save them to and
retrieve them from the database:

~~~ ruby
craig = User.new("booch", "Craig", 42)
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
fetch(id)             # Fetch a single domain model object by its primary key.
[id]                  # Fetch a single domain model object by its primary key.
query(sql_string)     # Runs SQL and returns a Preserves::SQL::ResultSet.
select(sql_string)    # Runs SQL and returns a Preserves::Selection.
select(sql_string, param1, param2)  # Include bind params for the SQL query.
select(sql_string, association_name: sql_result)  # Include associations.
~~~


### Preserves::SQL::ResultSet ###

~~~ ruby
result.size     # Number of rows that were affected by the SQL query.
~~~


### Preserves::Selection ###

A Selection is an Enumerable, representing the results of a SELECT query,
mapped to domain model objects.
Most of your interactions with Selections will be through the Enumerable interface.

~~~ ruby
selection.each      # Iterates through the resulting domain objects.
selection.first     # Returns the first result, or nil if there are no results.
selection.first!    # Returns the first result. Raises an exception if there are no results.
selection.last      # Returns the last result, or nil if there are no results.
selection.last!     # Returns the last result. Raises an exception if there are no results.
selection.only      # Returns the only result, or nil if there are no results. Raises an exception if there's more than 1 result. (Aliased as `one`.)
selection.only!     # Returns the only result. Raises an exception if there's not exactly 1 result. (Aliased as `one!`.)
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
