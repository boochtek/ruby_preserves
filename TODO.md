ASAP
----

* Use the stuff returned from JOINs instead of doing N+1 with a programmatically-built SQL query.
  * We're not actually using any of the stuff added by the JOIN clause in the has_many spec.
* has_many :through
  * Allow, but don't require, join table to have an associated Repository object.
  * Use AR syntax, but store them separately in Mapper.
* Make placeholders work.
  * Use them in our own code instead of hard-coding or string interpolation.


Soonish
-------

* Fix warnings.
* Rename Repository#hash_to_model_object.
  * Treat the hash as a Record Set.
* Convenience methods.
  * only (better matches with first/second/last) / only!
  * fetch / []
  * insert / update / save / delete
  * create_table
  * scope
* More coercions.
  * Move coercions to their own class(es).
    * Or should we use solnic/coercible gem?
  * Allow a way to specify more type mappings/coercions.
  	* Registration?
* Allow specifying SELECT statement for has_many proxy getter.
* Get default mappings from DB schema.
  * INTEGER
  * DATE
  * TIME
* Be consistent between strings and symbols.
* Allow strings in place of class names for specifying repositories.
  * Because we'll have circular references for belongs_to/has_many pairs.
  * Or should we not allow that, because it's bad for OOP to have circular dependencies?
    * Or maybe not allow belongs_to at all.
* Prepared statements.
* Should probably use a proxy object instead of a proxy method for associations/relations.
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
  * Allow a way to specify that a model is a value type (which doesn't have an identity).
    * Does it make sense to have these in the database?
* Test for mapping both type and name.
  * Probably already works.
* Transactions / Unit of Work.
* Use Mutant for testing.
* Use a CI service.
* Use Ruby 2.1 keyword arguments.
* Use cursors.
