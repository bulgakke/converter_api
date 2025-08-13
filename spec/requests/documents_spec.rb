require "swagger_helper"

RSpec.describe DocumentsController, type: :request do
  path "/documents" do
    post("upload a new document") do
      tags "Documents"
      consumes "application/json"
      produces "application/json"

      parameter name: :document, in: :body, schema: {
        type: :object,
        properties: {
          svg_content: { type: :string, format: :svg, example: File.read("spec/fixtures/files/base.svg") }
        },
        required: [ "svg_content" ]
      }

      response(200, "successful") do
        let(:document) { { svg_content: File.read("spec/fixtures/files/base.svg") } }
        after(&save_example)

        run_test!
      end

      response(422, "invalid SVG") do
        let(:document) { { svg_content: File.read("spec/fixtures/files/invalid.svg") } }
        after(&save_example)

        run_test!
      end
    end
  end
end
