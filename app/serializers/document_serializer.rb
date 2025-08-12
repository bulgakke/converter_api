class DocumentSerializer < ApplicationSerializer
  def as_json
    {
      pdf_url: rails_blob_url(record.pdf_file)
    }
  end
end
