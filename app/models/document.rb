class Document < ApplicationRecord
  has_one_attached :pdf_file

  # Doesn't matter for generating PDFs, but helps with caching
  # Not perfect (e. g. viewBox="0 0 1024 1024" and viewBox="0.0 0.0 1024.0 1024.0")
  # will still turn out different
  normalizes :svg_content, with: ->(value) {
    value.gsub(/<!--.*?-->/m, "") # remove comments
      .gsub(/\n+/, "") # remove newlines
      .squish # remove extra whitespace
  }

  validates :svg_content_hash, presence: true, uniqueness: true
  validates :svg_content, presence: true

  before_validation :update_svg_content_hash, if: :svg_content_changed?

  # If there is a document with the same SVG, returns it, otherwise creates a new one
  #
  # @param attributes [Hash] Document attributes
  #
  # @return [Document] Document
  def self.find_duplicate_or_initialize_by(attributes)
    normalized_svg = normalize_value_for(:svg_content, attributes[:svg_content])
    digest = Digest::SHA256.hexdigest(normalized_svg)

    find_or_initialize_by(svg_content_hash: digest) do |document|
      document.assign_attributes(attributes)
    end
  end

  # Generates PDF, saves it and returns true if everything is valid
  # Otherwise returns false
  #
  # @return [Boolean]
  def generate_pdf_and_save
    result = SVGToPDF.call(svg_content)

    if result.nil?
      errors.add(:svg_content, "not a valid SVG file")
      return false
    end

    ActiveRecord::Base.transaction do
      pdf_file.attach(io: StringIO.new(result.pdf), filename: "#{DateTime.now.utc.iso8601}.pdf", content_type: "application/pdf")
      return save
    end
  end

  private

  def update_svg_content_hash
    self.svg_content_hash = Digest::SHA256.hexdigest(svg_content)
  end
end
