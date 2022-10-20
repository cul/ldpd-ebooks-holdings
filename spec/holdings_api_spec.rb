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
      expect(last_response.status).to eq 400
    end
  end
  describe "GET /holdings/:bib_id.json" do
    let(:csv_path) { File.expand_path("../fixtures/test.csv", __FILE__) }
    context "has holdings" do
      let(:bib_id) { '12345' }
      let(:expected_url) { 'http://localhost/well-known-id' }
      before do
        HoldingsIndexer.update(":memory:", csv_path)
      end
      it "returns holdings" do
        get "/holdings/#{bib_id}.json"
        expect(last_response.status).to eq 200
        response_json = JSON.load(last_response.body)
        expect(response_json).to include({'id' => bib_id})
        expect(response_json['holdings']).to include({'test' => [expected_url]})
      end
    end
    context "has no holdings" do
      let(:bib_id) { '54321' }
      it "returns no holdings" do
        get "/holdings/#{bib_id}.json"
        expect(last_response.status).to eq 200
        expect(JSON.load(last_response.body)).to eq("id" => bib_id, "holdings" => {})
      end
    end
  end
end