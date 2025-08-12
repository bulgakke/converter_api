class Document < ApplicationRecord
  # Doesn't matter for generating PDFs, but helps with caching
  # Not perfect (e. g. viewBox="0 0 1024 1024" and viewBox="0.0 0.0 1024.0 1024.0")
  # will still turn out different
  normalizes :svg_content, with: ->(value) {
    value.gsub(/<!--.*?-->/m, "") # remove comments
      .gsub(/\n+/, "") # remove newlines
      .squish # remove extra whitespace
  }

  validates :svg_content, presence: true

  has_one_attached :pdf_file
end
