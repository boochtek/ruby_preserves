require "spec_helper"
require "preserves"


class User
  attr_accessor :id
end


describe "Mapper" do
  subject(:mapper) { Preserves::Mapper.new }

  describe "executing a query" do

    let(:query) { mapper.query("INSERT INTO users (username, name, age) VALUES ('booch', 'Craig', 43)") }

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
    describe "when DB has one user" do
      before do
        mapper.query("INSERT INTO users (username, name, age) VALUES ('booch', 'Craig', 43)")
      end

      let(:selection) { mapper.select("SELECT username AS id FROM users") }

      it "returns a set of 1 User object" do
        expect(selection.size).to eq(1)
        expect(selection.first.class).to eq(User)
      end

      it "sets the attributes on the object" do
        expect(selection.first.id).to eq("booch")
      end
    end
  end
end
