require 'rails_helper'

RSpec.describe Document, type: :model do
  describe "validations" do
    let(:document) { Document.new(svg_content:) }

    context "without svg_content" do
      let(:svg_content) { "" }

      it "is invalid" do
        expect(document).not_to be_valid
      end
    end

    context "with any text as svg_content" do
      let(:svg_content) { File.read("spec/fixtures/invalid.svg") }

      it "is valid" do
        expect(document).to be_valid
      end
    end
  end
end
