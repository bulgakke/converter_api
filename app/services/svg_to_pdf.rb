class SVGToPDF
  class ViewBox
    def initialize(viewbox_string, padding, margin)
      @min_x, @min_y, @width, @height = viewbox_string.split(" ").map(&:to_f)
      @padding = padding
      @margin = margin
    end

    def with_padding
      [
        @min_x - @padding,
        @min_y - @padding,
        @width + @padding * 2,
        @height + @padding * 2
      ]
    end

    def with_padding_and_margins
      [
        @min_x - @padding - @margin,
        @min_y - @padding - @margin,
        @width + @padding * 2 + @margin * 2,
        @height + @padding * 2 + @margin * 2
      ]
    end
  end

  PADDING = 100
  MARGIN = 100

  # @param svg_content [String] SVG as string
  # @return [String] PDF binary
  def self.call(svg_content)
    new(svg_content).call
  end

  def initialize(svg_content)
    @document = Nokogiri::XML(svg_content)
  end

  def call
    add_crop_marks!
    add_padding_and_margins!
    add_watermark!

    format_to_pdf
  end

  def to_s
    @document.to_s
  end

  private

  def svg
    @document.at_css("svg")
  end

  def viewbox
    @viewbox ||= ViewBox.new(svg["viewBox"], PADDING, MARGIN)
  end

  def add_crop_marks!
    rectangle = build_rectangle(*viewbox.with_padding)

    svg.add_child(rectangle)
  end

  def add_padding_and_margins!
    svg["viewBox"] = viewbox.with_padding_and_margins.join(" ")
  end

  def build_rectangle(x, y, width, height)
    rect = Nokogiri::XML::Node.new("rect", @document)
    rect["x"] = x
    rect["y"] = y
    rect["width"] = width
    rect["height"] = height
    rect["fill"] = "none"
    rect["stroke"] = "black"
    rect["stroke-width"] = "1"
    rect
  end

  def add_watermark!
    # TODO
  end

  def format_to_pdf
    MiniMagick::Image.read(@document.to_s)
      .format("pdf")
      .to_blob
  end
end
