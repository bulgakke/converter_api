class Document < ApplicationRecord
  validates :svg_content, presence: true

  has_one_attached :pdf_file
end
