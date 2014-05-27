require "spec_helper"
require "preserves"

describe "Mapper" do
  subject(:mapper) { Preserves::Mapper.new }

  describe "executing a query" do

    let(:query_result) { mapper.query("INSERT INTO 'users' (username, name, age) VALUES ('booch', 'Craig', 43)") }

    it "returns the number of rows processed" do
      expect(query_result.rows).to eq(1)
    end
  end
end
