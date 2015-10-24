require_relative "spec_helper"
require "preserves"

class Group
  attr_accessor :name
end

class User
  attr_accessor :id
  attr_accessor :age
  attr_accessor :addresses
  attr_accessor :group
end

class Address
  attr_accessor :city
end


AddressRepository = Preserves.repository(model: Address) do
  mapping do
    map :city, String
  end
end

GroupRepository = Preserves.repository(model: Group) do
  mapping do
    map :name, String
  end
end

UserRepository = Preserves.repository(model: User) do
  mapping do
    primary_key 'username'
    map id: 'username'
    map :age, Integer
    has_many :addresses, repository: AddressRepository, foreign_key: 'username'
    belongs_to :group, repository: GroupRepository
  end
end


describe "Repository" do

  subject(:repository) { UserRepository }

  describe "executing a query" do
    let(:query) { repository.query("INSERT INTO users (username, name, age) VALUES ($1, $2, $3)", 'booch', 'Craig', 43) }

    # This can't be done with let(), because we don't want to cache it.
    def number_of_rows_in_user_table
      Preserves::SQL.connection(dbname: "preserves_test").exec("SELECT COUNT(*) FROM users")[0]["count"].to_i
    end

    it "hits the database" do
      expect{ query }.to change{ number_of_rows_in_user_table }
    end

    it "returns the number of rows processed" do
      expect(query.size).to eq(1)
    end
  end

  describe "selecting results from a query to an object" do

    describe "when DB has 0 users" do
      let(:selection) { repository.select("SELECT username AS id FROM users") }

      it "works when restricting with `only`" do
        expect(selection.only).to eq(nil)
      end

      it "raises an exception when restricting with `only!`" do
        expect{ selection.only! }.to raise_exception("expected exactly 1 result")
      end

    end

    describe "when DB has 1 user" do
      before do
        repository.query("INSERT INTO users (username, name, age) VALUES ('booch', 'Craig', 43)")
      end

      let(:selection) { repository.select("SELECT username AS id FROM users") }

      it "returns a set of 1 User object" do
        expect(selection.size).to eq(1)
        expect(selection.first.class).to eq(User)
      end

      it "sets the attributes on the object" do
        expect(selection.first.id).to eq("booch")
      end

      it "works when restricting with `only`" do
        expect(selection.only.id).to eq("booch")
      end

      it "works when restricting with `only!`" do
        expect(selection.only!.id).to eq("booch")
      end
    end

    describe "when DB has 2 users" do
      before do
        repository.query("INSERT INTO users (username, name, age) VALUES ('booch', 'Craig', 43)")
        repository.query("INSERT INTO users (username, name, age) VALUES ('beth', 'Beth', 39)")
      end

      let(:selection) { repository.select("SELECT username AS id FROM users") }

      it "returns a set of 2 User objects" do
        expect(selection.size).to eq(2)
        expect(selection.first.class).to eq(User)
        expect(selection.last.class).to eq(User)
      end

      it "sets the attributes on the objects" do
        expect(selection.first.id).to eq("booch")
        expect(selection.last.id).to eq("beth")
      end

      it "raises an exception when restricting with `only`" do
        expect{ selection.only }.to raise_exception("expected only 1 result")
      end

      it "raises an exception when restricting with `only!`" do
        expect{ selection.only! }.to raise_exception("expected exactly 1 result")
      end

    end

    describe "when mapping a field name to a different model attribute name" do
      before do
        repository.query("INSERT INTO users (username, name, age) VALUES ('booch', 'Craig', 43)")
      end

      let(:selection) { repository.select("SELECT username FROM users") }

      it "sets the attribute on the object" do
        expect(selection.first.id).to eq("booch")
      end
    end

    describe "when mapping a field to an Integer" do
      before do
        repository.query("INSERT INTO users (username, name, age) VALUES ('booch', 'Craig', 43)")
      end

      let(:selection) { repository.select("SELECT age FROM users") }

      it "sets the attribute on the object to the right type" do
        expect(selection.first.age).to eq(43)
      end
    end

    describe "when mapping a field to an Integer" do
      before do
        repository.query("INSERT INTO users (username, name, age) VALUES ('booch', 'Craig', 43)")
      end

      let(:selection) { repository.select("SELECT age FROM users") }

      it "sets the attribute on the object to the right type" do
        expect(selection.first.age).to eq(43)
      end
    end

    describe "when mapping a has_many relation" do
      before do
        repository.query("INSERT INTO users (username, name, age) VALUES ('booch', 'Craig', 43)")
        repository.query("INSERT INTO users (username, name, age) VALUES ('beth', 'Beth', 39)")
        repository.query("INSERT INTO addresses (city, username) VALUES ('Overland', 'booch')")
        repository.query("INSERT INTO addresses (city, username) VALUES ('Wildwood', 'booch')")
        repository.query("INSERT INTO addresses (city, username) VALUES ('Ballwin', 'booch')")
        repository.query("INSERT INTO addresses (city, username) VALUES ('Ballwin', 'beth')")
        repository.query("INSERT INTO addresses (city, username) VALUES ('Keokuk', 'unknown')")
      end

      let(:address_query) { repository.query("SELECT * FROM addresses") }
      let(:selection) { repository.select("SELECT * FROM users", addresses: address_query) }

      it "gets the basic fields" do
        expect(selection.first.id).to eq('booch')
        expect(selection.first.age).to eq(43)
        expect(selection.last.id).to eq('beth')
        expect(selection.last.age).to eq(39)
      end

      it "gets all the related items" do
        expect(selection.first.addresses).to_not be(nil)
        expect(selection.first.addresses.size).to eq(3)
        expect(selection.first.addresses.map(&:city)).to include("Overland")
        expect(selection.first.addresses.map(&:city)).to include("Wildwood")
        expect(selection.first.addresses.map(&:city)).to include("Ballwin")
        expect(selection.last.addresses).to_not be(nil)
        expect(selection.last.addresses.size).to eq(1)
        expect(selection.last.addresses.map(&:city)).to include("Ballwin")
      end

    end

  end

end
