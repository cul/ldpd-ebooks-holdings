require "spec_helper"
require "tmpdir"

RSpec.describe HoldingsIndexer do
  around do |example|
    Dir.mktmpdir do |dir|
      @dir = dir
      example.run
    end
  end

  let(:db_path) { File.join(@dir, "test.sqlite3") }

  def write_csv(name, rows)
    path = File.join(@dir, name)
    File.write(path, "bib_id,provider,url\n" + rows.map { |r| r.join(",") }.join("\n") + "\n")
    path
  end

  def links
    SQLite3::Database.new(db_path).execute("SELECT bib_id, provider, url FROM ebook_links ORDER BY bib_id, provider")
  end

  describe ".update" do
    it "inserts new rows" do
      described_class.update(db_path, write_csv("a.csv", [["1", "p1", "http://x/1"], ["2", "p1", "http://x/2"]]))
      expect(links).to eq([["1", "p1", "http://x/1"], ["2", "p1", "http://x/2"]])
    end

    it "updates the url of an existing bib_id/provider on re-import" do
      described_class.update(db_path, write_csv("a.csv", [["1", "p1", "http://x/old"], ["1", "p2", "http://x/keep"]]))
      described_class.update(db_path, write_csv("b.csv", [["1", "p1", "http://x/new"], ["3", "p1", "http://x/3"]]))
      expect(links).to eq([
        ["1", "p1", "http://x/new"],
        ["1", "p2", "http://x/keep"],
        ["3", "p1", "http://x/3"]
      ])
    end

    it "treats values containing quotes as data, not SQL" do
      described_class.update(db_path, write_csv("a.csv", [["1", "p1", %q("http://x/o'brien")]]))
      expect(links).to eq([["1", "p1", "http://x/o'brien"]])
    end

    it "creates the schema indexes" do
      described_class.update(db_path)
      names = SQLite3::Database.new(db_path).execute("SELECT name FROM sqlite_master WHERE type = 'index'").flatten
      expect(names).to include("bib_id_index", "provider_index", "bib_id_provider_index")
    end
  end

  describe ".reindex" do
    it "accepts a database path" do
      described_class.update(db_path, write_csv("a.csv", [["1", "p1", "http://x/1"]]))
      expect { described_class.reindex(db_path) }.not_to raise_error
    end
  end
end
