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


AddressRepository = Preserves.repository(model: Address, dataset: DB[:addresses]) do
  mapping do
    map :city, String
  end
end

GroupRepository = Preserves.repository(model: Group, dataset: DB[:groups]) do
  mapping do
    map :name, String
  end
end

UserRepository = Preserves.repository(model: User, dataset: DB[:users]) do
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

  # describe "executing a query" do
  #   let(:query) { DB.run("INSERT INTO users (username, name, age) VALUES ($1, $2, $3)", 'booch', 'Craig', 43) }
  #
  #   # This can't be done with let(), because we don't want to cache it.
  #   def number_of_rows_in_user_table
  #     DB[:users].all.size
  #   end
  #
  #   it "hits the database" do
  #     expect{ query }.to change{ number_of_rows_in_user_table }
  #   end
  #
  #   it "returns the number of rows processed" do
  #     expect(query.size).to eq(1)
  #   end
  # end

  describe "selecting results from a query to an object" do

    describe "when DB has 0 users" do
      let(:dataset) { repository.dataset }
      let(:selection) { repository.all }

      it "works when restricting with `only`" do
        expect(selection.only).to eq(nil)
      end

      it "raises an exception when restricting with `only!`" do
        expect{ selection.only! }.to raise_exception("expected exactly 1 result")
      end

      it "raises an exception when restricting with `first!`" do
        expect{ selection.first! }.to raise_exception("expected at least 1 result")
      end

      it "raises an exception when restricting with `last!`" do
        expect{ selection.last! }.to raise_exception("expected at least 1 result")
      end

    end

    describe "when DB has 1 user" do
      before do
        DB.run("INSERT INTO users (username, name, age) VALUES ('booch', 'Craig', 43)")
      end

      let(:dataset) { repository.dataset }
      let(:selection) { repository.all }

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

      it "works when restricting with `first!`" do
        expect(selection.first!.id).to eq("booch")
      end

      it "works when restricting with `last!`" do
        expect(selection.last!.id).to eq("booch")
      end
    end

    describe "when DB has 2 users" do

      before do
        DB.run("INSERT INTO users (username, name, age) VALUES ('booch', 'Craig', 43)")
        DB.run("INSERT INTO users (username, name, age) VALUES ('beth', 'Beth', 39)")
      end

      let(:dataset) { repository.dataset }
      let(:selection) { repository.all }

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

      it "can fetch the objects by ID" do
        expect(repository.fetch('booch').class).to eq(User)
        expect(repository.fetch('booch').age).to eq(43)
        expect(repository['booch'].class).to eq(User)
        expect(repository['booch'].age).to eq(43)
        expect(repository.fetch!('booch').class).to eq(User)
        expect(repository.fetch!('booch').age).to eq(43)
        expect{ repository.fetch!('unknown') }.to raise_exception("expected exactly 1 result")
      end
    end

    describe "when mapping a field name to a different model attribute name" do
      before do
        DB.run("INSERT INTO users (username, name, age) VALUES ('booch', 'Craig', 43)")
      end

      let(:dataset) { repository.dataset }
      let(:selection) { repository.all }

      it "sets the attribute on the object" do
        expect(selection.first.id).to eq("booch")
      end
    end

    describe "when mapping a field to an Integer" do
      before do
        DB.run("INSERT INTO users (username, name, age) VALUES ('booch', 'Craig', 43)")
      end

      let(:dataset) { repository.dataset }
      let(:selection) { repository.all }

      it "sets the attribute on the object to the right type" do
        expect(selection.first.age).to eq(43)
      end
    end

    describe "when mapping a field to an Integer" do
      before do
        DB.run("INSERT INTO users (username, name, age) VALUES ('booch', 'Craig', 43)")
      end

      let(:dataset) { repository.dataset }
      let(:selection) { repository.all }

      it "sets the attribute on the object to the right type" do
        expect(selection.first.age).to eq(43)
      end
    end

    # describe "when mapping a has_many relation" do
    #   before do
    #     DB.run("INSERT INTO users (username, name, age) VALUES ('booch', 'Craig', 43)")
    #     DB.run("INSERT INTO users (username, name, age) VALUES ('beth', 'Beth', 39)")
    #     DB.run("INSERT INTO addresses (city, username) VALUES ('Overland', 'booch')")
    #     DB.run("INSERT INTO addresses (city, username) VALUES ('Wildwood', 'booch')")
    #     DB.run("INSERT INTO addresses (city, username) VALUES ('Ballwin', 'booch')")
    #     DB.run("INSERT INTO addresses (city, username) VALUES ('Ballwin', 'beth')")
    #     DB.run("INSERT INTO addresses (city, username) VALUES ('Keokuk', 'unknown')")
    #   end
    #
    #   let(:address_query) { DB.run("SELECT * FROM addresses") }
    #   let(:selection) { repository.select("SELECT * FROM users", addresses: address_query) }
    #
    #   it "gets the basic fields" do
    #     expect(selection.first.id).to eq('booch')
    #     expect(selection.first.age).to eq(43)
    #     expect(selection.last.id).to eq('beth')
    #     expect(selection.last.age).to eq(39)
    #   end
    #
    #   it "gets all the related items" do
    #     expect(selection.first.addresses).to_not be(nil)
    #     expect(selection.first.addresses.size).to eq(3)
    #     expect(selection.first.addresses.map(&:city)).to include("Overland")
    #     expect(selection.first.addresses.map(&:city)).to include("Wildwood")
    #     expect(selection.first.addresses.map(&:city)).to include("Ballwin")
    #     expect(selection.last.addresses).to_not be(nil)
    #     expect(selection.last.addresses.size).to eq(1)
    #     expect(selection.last.addresses.map(&:city)).to include("Ballwin")
    #   end
    #
    # end
    #
    # describe "when mapping a belongs_to relation" do
    #   before do
    #     DB.run("INSERT INTO groups (id, name) VALUES (1, 'admin')")
    #     DB.run("INSERT INTO groups (id, name) VALUES (2, 'users')")
    #     DB.run("INSERT INTO users (username, name, age, group_id) VALUES ('booch', 'Craig', 43, 1)")
    #     DB.run("INSERT INTO users (username, name, age, group_id) VALUES ('beth', 'Beth', 39, 2)")
    #   end
    #
    #   let(:group_query) { DB.run("SELECT * FROM groups") }
    #   let(:selection) { repository.select("SELECT * FROM users", group: group_query) }
    #
    #   it "gets the basic fields" do
    #     expect(selection.first.id).to eq('booch')
    #     expect(selection.first.age).to eq(43)
    #     expect(selection.last.id).to eq('beth')
    #     expect(selection.last.age).to eq(39)
    #   end
    #
    #   it "gets all the related items" do
    #     expect(selection.first.group).to_not be(nil)
    #     expect(selection.first.group).to be_a(Group)
    #     expect(selection.first.group.name).to eq("admin")
    #     expect(selection.last.group).to_not be(nil)
    #     expect(selection.last.group).to be_a(Group)
    #     expect(selection.last.group.name).to eq("users")
    #   end
    #
    # end

  end

end
