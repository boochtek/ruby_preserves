TODO
====


Presentation
------------

* Create the short URL. (NO UNDERSCORES)
    * http://tinyurl.com/ruby-preserves-rubyconf
    * https://rawgit.com/booch/presentations/Ruby_Preserves-RubyConf-2015-11-15/Ruby_Preserves/slides.html


ASAP
----

* Figure out how ActiveRecord and Sequel do joins.
    * We're currently doing the join manually.
        * This is probably OK for reasonably-sized queries.
        * Because we couldn't figure out how to map the results of SQL JOINs.
            * The tricky part is sorting out all the result set attributes.
                * Which attributes belong to the parent, and which to the child?
* Finish up eager loading stuff.
    * has_many_through
    * belongs_to
* Convenience methods.
    * fetch / [] / fetch!
        * To get models by primary key.
    * first! / last!
        * To mirror one! (throw exception if the list is empty).
    * insert / update / save / delete
    * create_table
    * scope
* Show how to use a different repository for tests, if necessary.
    * Like an in-memory repository.
    * I assume we'd have to use a completely different repository.
        * Since we require SQL, we can't really do in-memory.
* Show examples using foreign keys and PostgreSQL arrays.
    * Probably advise NOT to do belongs_to mappings.
* has_many :through
    * Allow, but don't require, join table to have an associated Repository object.
    * Use AR syntax, but store them separately in Mapper.
* Preserves.repository() should return a module to mix in, and not take a block.
    * And should not be singletons.
        * Might use method_missing on class to allow usage as if it's a singleton.
    * Use the Module Factory pattern.


Soonish
-------

* Fix warnings.
* More coercions.
    * Move coercions to their own class(es).
        * Or should we use solnic/coercible gem?
    * Allow a way to specify more type mappings/coercions.
    	 * Registration?
* Get default mappings from DB schema.
    * INTEGER
    * DATE
    * TIME
* Prepared statements.
* Examples of pagination.
* Be consistent between strings and symbols.
* Allow strings in place of class names for specifying repositories.
    * Because we'll have circular references for belongs_to/has_many pairs.
    * Or should we not allow that, because it's bad for OOP to have circular dependencies?
        * Or maybe not allow belongs_to at all.
* Unit tests.
    * We currently only have integration/acceptance tests.


Deferred
--------

These can be deferred until after we've proven out the concept.

* Cleanup.
    * Setting up DB in spec_helper is terrible.
        * At least move it to a separate file.
    * Should Repository#query and #select be protected?
        * We're using #select in Mapper#add_has_many_proxies.
            * We could make a separate public method for him to use.
* Better documentation.
    * README isn't great at explaining how to use it.
    * Should make recommendations on how to use this.
        * In Rails, recommend putting repositories in app/repositories/.
            * Add that to LOAD_PATH, but don't auto-load.
        * Repository file should require domain model file, but never vice-versa.
        * Recommend they consider using 'Users' instead of 'UserRepository'.
* Handle Virtus models.
    * Get list of default mappings from model attributes list.
    * New up the object with all attributes, instead of setting them individually.
    * Will probably make this a separate gem.
        * Can layer on top, or inject extra strategies for object creation and default mappings.
* Identity map.
    * For cases where we're creating a bunch of objects, but some already exist.
    * Allow a way to specify that a model is a value type (which doesn't have an identity).
        * Does it make sense to have these in the database?
* Test for mapping both type and name.
    * Probably already works.
* Transactions / Unit of Work.
* Use Mutant for testing.
* Use a CI service.
* Use Ruby 2.1 keyword arguments.
* Use cursors.
* Performance testing.
