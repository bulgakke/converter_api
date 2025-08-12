require 'rails_helper'

RSpec.describe Document, type: :model do
  describe ".find_duplicate_or_initialize_by" do
    subject(:result) { Document.find_duplicate_or_initialize_by(svg_content:) }

    let(:svg_content) { "asdf" }

    context "when there is no document with the same SVG" do
      it "returns a new document with passed attributes" do
        expect(result).to be_a(Document)
        expect(result.persisted?).to be false
        expect(result.svg_content).to eq svg_content
      end
    end

    context "when there is a document with the same SVG" do
      let!(:document) { create(:document, svg_content:) }

      it "returns the document" do
        expect(result).to eq document
        expect(result.persisted?).to be true
      end
    end
  end

  describe "#generate_pdf_and_save" do
    let(:document) { build(:document, svg_content:) }

    context "with valid SVG" do
      let(:svg_content) { File.read("spec/fixtures/files/base.svg") }
      let(:service_call) { instance_double(SVGToPDF, pdf: "pdf") }

      before {
        allow(SVGToPDF).to receive(:call).and_return(service_call)
      }

      it "saves document, attaches PDF and returns true" do
        expect(document.generate_pdf_and_save).to be true
        expect(document.pdf_file.attached?).to be true
        expect(document.persisted?).to be true
      end
    end

    context "with invalid SVG" do
      let(:svg_content) { File.read("spec/fixtures/files/invalid.svg") }

      before {
        allow(SVGToPDF).to receive(:call).and_return(nil)
      }

      it "does not save document, does not attach PDF and returns false" do
        expect(document.generate_pdf_and_save).to be false
        expect(document.pdf_file.attached?).to be false
        expect(document.persisted?).to be false
      end
    end
  end

  describe "validations" do
    let(:document) { build(:document, svg_content:) }

    context "without svg_content" do
      let(:svg_content) { "" }

      it "is invalid" do
        expect(document).not_to be_valid
      end
    end

    context "with any text as svg_content" do
      let(:svg_content) { File.read("spec/fixtures/files/invalid.svg") }

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
