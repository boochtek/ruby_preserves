require "spec_helper"
require "preserves"


class User
  attr_accessor :id
  attr_accessor :age
end


UserRepository = Preserves.repository(model: User) do
  mapping do
    primary_key 'username'
    map id: 'username'
    map :age, Integer
  end
end


describe "Repository" do
  subject(:repository) { UserRepository }

  describe "executing a query" do

    let(:query) { repository.query("INSERT INTO users (username, name, age) VALUES ('booch', 'Craig', 43)") }

    # This can't be done with let(), because we don't want to cache it.
    def rows_in_user_table
      Preserves::SQL.connection(dbname: "preserves_test").exec("SELECT COUNT(*) FROM users")[0]["count"].to_i
    end

    it "hits the database" do
      expect{ query }.to change{ rows_in_user_table }
    end

    it "returns the number of rows processed" do
      expect(query.rows).to eq(1)
    end
  end

  describe "selecting results from a query to an object" do
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

  end
end
