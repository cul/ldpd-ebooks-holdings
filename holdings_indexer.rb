require_relative 'holdings_api'
require 'csv'
require 'sqlite3'

class HoldingsIndexer
	def self.init_db(db_path)
		db = SQLite3::Database.new db_path
		schema_path = File.expand_path("../config/schema.sql", __FILE__)
		db.execute File.read(schema_path)
		db
	end

	def self.get(db, bib_id, provider)
		db.execute <<-SQL
		SELECT bib_id,provider,url FROM ebook_links WHERE bib_id = '#{bib_id}' AND provider = '#{provider}';
		SQL
	end

	def self.update(db_path, csv_path = nil)
		db = init_db(db_path)
		if csv_path
			puts csv_path
			CSV.foreach(csv_path, headers: true) do |row|
				if get(db, row['bib_id'], row['provider'])
					db.execute <<-SQL
					INSERT INTO ebook_links(bib_id,provider,url) VALUES('#{row['bib_id']}','#{row['provider']}','#{row['url']}');
					SQL
				else
					db.execute <<-SQL
						UPDATE ebook_links
						SET url = ?
						WHERE ebook_links.bib_id = ? AND ebook_links.provider = ?
						VALUES('#{row['url']}','#{row['bib_id']}','#{row['provider']}');
 					SQL
				end
			end
		end
		reindex(db)
	end

	# This method is not called until TinyCDB index is available
	def self.reindex(db_or_path)
		db = String === db_or_path ? init_db(db_path) : db_or_path
		LibCDB::CDB.open(HoldingsApi.settings.datastore_path, 'w') do | cdb |
			bib_doc = nil
			db.execute( "SELECT bib_id, provider, url FROM ebook_links ORDER BY bib_id" ) do |row|
				bib_doc = {id: row[0], holdings: {}} if bib_doc.nil?
				if bib_doc[:id] != row[0]
					cdb[bib_doc[:id]] = JSON.generate(bib_doc[:holdings])
					bib_doc = {id: row[0], holdings: {}}
				end
				bib_doc[:holdings][row[1]] = [row[2]]
			end
			if bib_doc
				cdb[bib_doc.delete(:id)] = JSON.generate(bib_doc[:holdings])
			end
		end
	end
end