require "spec_helper"
RSpec.describe HoldingsApi do
  def app
    HoldingsApi # this defines the active application for this test
  end

  describe "GET /" do      
    it "returns a 404" do
      get "/"
      expect(last_response.status).to eq 404
    end
  end
  describe "GET /holdings" do      
    it "returns a 404" do
      get "/holdings"
      expect(last_response.status).to eq 404
    end
  end
  describe "GET /holdings/:bib_id.json" do
    let(:bib_id) { '12345' }
    let(:json_data) { { 'msg' => 'Test' } }
    context "has holdings" do
      before do
        LibCDB::CDB.open(described_class.settings.datastore_path, 'w') do | cdb |
          cdb[bib_id] = JSON.generate(json_data)
        end
      end
      it "returns holdings" do
        get "/holdings/12345.json"
        expect(last_response.status).to eq 200
        expect(JSON.load(last_response.body)).to eq(json_data)
      end
    end
    context "has no holdings" do
      before do
        LibCDB::CDB.open(described_class.settings.datastore_path, 'w') { | cdb | }
      end
      it "returns no holdings" do
        get "/holdings/12345.json"
        expect(last_response.status).to eq 200
        expect(JSON.load(last_response.body)).to eq("id" => bib_id, "holdings" => {})
      end
    end
  end
end