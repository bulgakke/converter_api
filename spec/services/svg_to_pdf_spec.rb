require "rails_helper"

RSpec.describe SVGToPDF do
  describe ".call" do
    subject(:result) { SVGToPDF.call(svg_content) }

    let(:svg_content) { "asdf" }

    it "returns a blob" do
      expect(result).to be_a(String)
    end
  end
end
