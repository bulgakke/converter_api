require 'rails_helper'

RSpec.describe Document, type: :model do
  describe "validations" do
    context "without svg_content" do
      it "is invalid" do
        document = Document.new(svg_content: "")
        expect(document).not_to be_valid
      end
    end

    context "with any text as svg_content" do
      it "is valid" do
        document = Document.new(svg_content: "asdf")
        expect(document).to be_valid
      end
    end
  end
end
