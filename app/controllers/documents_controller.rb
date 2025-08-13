class DocumentsController < ApplicationController
  def create
    document = Document.find_duplicate_or_initialize_by(document_params)

    if document.persisted? || document.generate_pdf_and_save
      render json: serialize(document), status: :ok
    else
      render json: { errors: document.errors }, status: :unprocessable_content
    end
  end

  private

  def document_params
    params.permit(:svg_content)
  end
end
