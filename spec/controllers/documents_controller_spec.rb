require "rails_helper"

RSpec.describe DocumentsController, type: :controller do
  describe "#create" do
    let(:send_request) { post :create, params: }

    context "when document with this SVG already exists" do
      let!(:existing_document) { create(:document, :with_pdf) }
      let(:params) { { svg_content: existing_document.svg_content } }

      it "does not create a new document" do
        expect { send_request }.not_to change(Document, :count)
      end

      it "returns existing document" do
        send_request
        expect(response).to have_http_status(:ok)
        expect(json_response).to eq serialize(existing_document)
      end
    end

    context "when document with this SVG does not exist" do
      let(:expected_document) { Document.find_by(svg_content: params[:svg_content]) }

      context "when SVG is valid" do
        let(:params) { { svg_content: File.read("spec/fixtures/files/base.svg") } }

        let(:expected_data) do
          {
            pdf_url: rails_blob_url(expected_document.pdf_file)
          }
        end

        before do
          expect(SVGToPDF).to receive(:call).and_return(instance_double(SVGToPDF, pdf: "pdf"))
        end

        it "creates a new document" do
          expect { send_request }.to change(Document, :count).by(1)
          expect(expected_document.persisted?).to be true
          expect(expected_document.pdf_file.attached?).to be true
        end

        it "returns created document" do
          send_request
          expect(response).to have_http_status(:ok)
          expect(json_response).to eq expected_data
        end
      end

      context "when SVG is invalid" do
        let(:params) { { svg_content: 'asdf' } }

        let(:expected_errors) do
          {
            svg_content: [ "not a valid SVG file" ]
          }
        end

        before do
          expect(SVGToPDF).to receive(:call).and_return(nil)
        end

        it "does not create a new document" do
          expect { send_request }.not_to change(Document, :count)
          expect(expected_document).to be_nil
        end

        it "does not create a PDF file" do
          expect { send_request }.not_to change(ActiveStorage::Blob, :count)
        end

        it "returns errors" do
          send_request
          expect(response).to have_http_status(:unprocessable_content)
          expect(json_response).to eq expected_errors
        end
      end
    end
  end
end
