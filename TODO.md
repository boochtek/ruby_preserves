TODO
====


ASAP
----

* Add logo to repo and README (both branches).
* Sequel has_many and belongs_to.
* README: Document has_many and belongs_to.
    * Advise to avoid belongs_to mappings, if possible.
        * Especially don't want circular dependencies.
* README: Show an example of pagination.
* README: Show how to use a different repository for tests, if necessary.
* Saving.
    * insert / update / save / delete
* Preserves.repository() should return a module to mix in, and not take a block.
    * And should not be singletons.
        * Might use method_missing on class to allow usage as if it's a singleton.
    * Use the Module Factory pattern.


Soonish
-------

* Convenience methods.
    * create_table
    * scope
* Don't require `model` keyword in Repository initializer (suggested by @jeg2).
* More coercions.
    * Boolean
    * Date
    * Rename to serialize/deserialize.
    * Move serializers to their own class(es).
        * Or should we use solnic/coercible gem?
    * Allow a way to specify more type mappings/serializers.
    	 * Registration?
* Get default mappings from DB schema.
    * INTEGER
    * DATE
    * TIME
* Prepared statements.
    * Can we just prepare every Sequel query we run?
        * Would obviously want to make this a LRU cache eventually.
* Ensure we can use PostgreSQL arrays.
* Be consistent between strings and symbols.
* Transactions.
    * Probably needs some support in the ORM.
* Can we initialize the domain model objects, instead of using setters?
    * Would initialize with a Hash of attributes and values.
    * Might allow both variants, to work with different kinds of classes.
    * Would need a way to know if the model class supports the initializer we'd be using.
* Allow strings in place of class names for specifying repositories.
    * Because we'll have circular references for belongs_to/has_many pairs.
    * Or should we not allow that, because it's bad for OOP to have circular dependencies?
* Better exceptions -- add some Exception classes.
* Have Selection class lazily do mapping, instead of eagerly in the repository?
* Unit tests.
    * We currently only have integration/acceptance tests.
    * Pluralize.
        * Will have to move it to its own file and make it public.
* Add has_many :through relations.
    * Might already work with the existing code, and just need testing.
    * Allow, but don't require, join table to have an associated Repository object.
    * Use ActiveRecord syntax, but store them separately in Mapper.
* Should we catch exceptions from the DB?
    * Should we reraise them with our own exception class?
    * Should we swallow them?
* Cleanup.
    * Clean up Mapper a bit more.
    * Setting up the DB in spec_helper is terrible.
        * At least move it to a separate file.
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
* Fit into ActiveModel.
    * Would require picking one base class for models.
        * Would lose the ability to use POROs (at least when using ActiveModel).
    * Would require mutual dependencies.
        * The model will have to call to the repo to persist itself.
        * The repo will need to know about the model.
            * Maybe there's a way to actually break this, since our mapping doesn't need it immediately.
    * Would require also including a validation layer (I think).
* Connection pooling.
* Is there a way we could do dirty tracking/updating?
    * This would require some help from the model.
        * So we'd probably make it optional, depending on whether the model supports it.
* Is there a way we could do optimistic locking?
* Is there a way we could do lazy loading of associations?
* Transactions / Unit of Work.
* Can we use change sets and move writing to a separate class?
    * Implements CQRS pattern, which is a good thing.
    * Not sure where the Change Sets would go.
    * But it seems like the Repo object still should represent the data set.
    * Change sets could be where the majority of the validation and coercion happens.
* Composite keys.
* Use Mutant for testing.
* Use a CI service.
* Use Ruby 2.1 keyword arguments.
* Performance testing.
