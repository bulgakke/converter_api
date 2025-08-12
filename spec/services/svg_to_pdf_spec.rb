require "rails_helper"

RSpec.describe SVGToPDF do
  describe ".call" do
    subject(:result) { SVGToPDF.call(svg_content) }

    context "with valid SVG" do
      let(:svg_content) { File.read("spec/fixtures/files/base.svg") }

      before {
        # Watermark is randomly rotated, fix rand for tests
        allow_any_instance_of(SVGToPDF).to receive(:random_angle).and_return(0)
      }

      it "forms expected SVG" do
        expect(result.svg).to eq File.read("spec/fixtures/files/result.svg")
      end

      it "converts to PDF" do
        expect(result.pdf).to be_a(String)

        # Quick check, PDFs are hard to verify
        expect(result.pdf.start_with?("%PDF-")).to be true
      end
    end

    context "with invalid SVG" do
      let(:svg_content) { File.read("spec/fixtures/files/invalid.svg") }

      it "returns nil" do
        expect(result).to be_nil
      end
    end
  end
end
