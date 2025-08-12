class SVGToPDF
  # @param document [Document] Document record
  # @return [String] PDF binary
  def self.call(document)
    new(document).call
  end

  def initialize(document)
    @tempfile = MiniMagick::Image.read(document.svg_content)
  end

  def call
    add_crop_marks!
    add_watermark!
    @tempfile.format("pdf")

    @tempfile.to_blob
  end

  private

  def add_crop_marks!
    # TODO
  end

  def add_watermark!
    # TODO
  end
end
