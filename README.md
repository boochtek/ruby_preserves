Preserves
=========

Preserves is a minimalist ORM (object-relational mapper) for Ruby,
using the Data Mapper pattern instead of the Active Record pattern.
It's built atop Jeremy Evans' excellent [Sequel] library.

We're trying to answer this question:

* How simple can we make an ORM that is still useful?

This ORM is based on a few strong opinions:

* The Data Mapper pattern is generally better than the Active Record pattern.
    * Unless you're just writing a CRUD front-end, with little interesting behavior.
* Declaring attributes in the domain model is better than hiding them elsewhere.
    * Declaring relationships in one place and attributes in another is true madness.

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

First, create your domain model class. You can use a [Struct], an
[OpenStruct], a [Virtus] model, or a plain old Ruby object (PORO) class.
We'll use a Struct in the examples, so we can initialize the fields easily.

~~~ ruby
User = Struct.new(:id, :name, :age) do
end
~~~

Next, configure the Sequel data store.

~~~ ruby
DB = Sequel.connect('postgres://user:password@localhost/my_db')
~~~

Then create a repository linked to the domain model class
and the Sequel dataset.
By default, all attributes will be assumed to be Strings.
For other attribute types, you'll need to supply the mapping.
(We'll have some default mappings determined from the DB or model later.)
Your repository should then define methods to access model objects
in the database. (These will mostly be like ActiveRecord scopes.)

~~~ ruby
UserRepository = Preserves.repository(model: User, dataset: DB[:users]) do

  # Declare how to map items in the dataset to objects in our class.
  mapping do
    map id: 'username'  # The database field named 'username' corresponds to the 'id' attribute in the model.
    map :name
    map :age, Integer   # The 'age' field should be mapped to an Integer in the model.
  end

  def older_than(minimum_age)
    map(dataset.where('age >= :minimum_age', minimum_age: minimum_age))
  end

  def with_name(name)
    map(dataset.where(name: name))
  end
end
~~~

Now we can create model objects and use the repository to save them to and
retrieve them from the database:

~~~ ruby
craig = User.new("booch", "Craig", 42)
UserRepository.insert(craig)
users_over_40 = UserRepository.older_than(40)   # Returns an Enumerable set of User objects.
beth = UserRepository.with_name("Beth").one     # Returns a single User object or nil.
~~~


API Summary
-----------

NOTE: This project is in very early exploratory stages.
The API **will** change.


### Repository ###

Most of the API you'll use will be in the your repository object.
The mixin provides the following methods:

~~~ ruby
map_one               # Map one item (hash) from a Sequel dataset to an object.
map                   # Map a Sequel dataset to a Selection (collection of objects).
dataset               # Sequel dataset for all objects.
insert(object)        # Insert object into the database.
fetch(id)             # Fetch a single domain model object by its primary key.
[id]                  # Fetch a single domain model object by its primary key.
all                   # Alias for `map(dataset)`.
~~~


### Preserves::Selection ###

A Selection is an Enumerable, representing the results of a SELECT query,
mapped to domain model objects.
Most of your interactions with Selections will be through the Enumerable interface.

~~~ ruby
selection.each      # Iterates through the resulting domain objects.
selection.first     # Returns the first result. Returns nil if there are no results.
selection.first!    # Returns the first result. Raises an exception if there are no results.
selection.last      # Returns the last result. Returns nil if there are no results.
selection.last!     # Returns the last result. Raises an exception if there are no results.
selection.only      # Returns the only result. Returns nil if there are no results. Raises an exception if there's more than 1 result. (Aliased as `one`.)
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


[Sequel]: http://sequel.jeremyevans.net/
[Struct]: http://ruby-doc.org/core-2.2.0/Struct.html
[OpenStruct]: http://ruby-doc.org/stdlib-2.2.0/libdoc/ostruct/rdoc/OpenStruct.html
[Virtus]: https://github.com/solnic/virtus#readme

[project repo]: https://github.com/boochtek/ruby_preserves/fork
[pull request]: https://github.com/boochtek/ruby_preserves/pulls
