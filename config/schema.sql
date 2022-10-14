CREATE TABLE IF NOT EXISTS ebook_links (
	id    INTEGER PRIMARY KEY,
	bib_id VARCHAR(16),
	provider VARCHAR(16),
	url VARCHAR(512)
);

CREATE INDEX IF NOT EXISTS bib_id_index on ebook_links(bib_id);
CREATE INDEX IF NOT EXISTS provider_index on ebook_links(provider);
CREATE UNIQUE INDEX IF NOT EXISTS bib_id_provider_index on ebook_links(bib_id, provider);