require "spec_helper"
require "preserves"


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
end
