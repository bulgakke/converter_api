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

  describe "normalizations" do
    describe "svg_content" do
      let(:raw_svg) do
        <<~SVG
          <!-- comment -->
          <svg width="100" height="100">
            <rect x="10" y="10" width="80" height="80"/>
          </svg>

        SVG
      end

      let(:expected_svg) do
        '<svg width="100" height="100"> <rect x="10" y="10" width="80" height="80"/></svg>'
      end

      it "removes comments, newlines and squishes whitespace" do
        expect(Document.normalize_value_for(:svg_content, raw_svg)).to eq(expected_svg)
      end

      it "does not alter already normalized svg_content" do
        expect(Document.normalize_value_for(:svg_content, expected_svg)).to eq(expected_svg)
      end

      it "does not change blank strings" do
        expect(Document.normalize_value_for(:svg_content, "")).to eq("")
      end

      it "does not break on other types" do
        expect(Document.normalize_value_for(:svg_content, "1")).to eq("1")
      end

      it "leaves nil as nil" do
        expect(Document.normalize_value_for(:svg_content, nil)).to be_nil
      end
    end
  end
end
