class ApplicationSerializer
  include Rails.application.routes.url_helpers

  attr_reader :record

  def initialize(record)
    @record = record
  end
end
