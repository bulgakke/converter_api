require "rails_helper"

RSpec.describe DocumentSerializer do
  subject(:result) { DocumentSerializer.new(document).as_json }

  let(:document) { create(:document, :with_pdf) }

  let(:expected_result) do
    {
      pdf_url: rails_blob_url(document.pdf_file)
    }
  end

  it "returns expected result" do
    expect(result).to eq expected_result
  end
end
