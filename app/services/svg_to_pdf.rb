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

  class Size
    MAX_SIZE = 1000

    attr_reader :new_width, :new_height

    def initialize(width, height)
      @width = width.to_f
      @height = height.to_f
      resize!
    end

    def h_w_ratio
      @height / @width
    end

    def resize!
      if h_w_ratio > 1
        @new_height = MAX_SIZE
        @new_width = @new_height / h_w_ratio
      else
        @new_width = MAX_SIZE
        @new_height = @new_width * h_w_ratio
      end
    end
  end

  PADDING = 100
  MARGIN = 100
  WATERMARK_TEXT = "github.com/bulgakke".freeze

  # @param svg_content [String] SVG as string
  # @return [String] PDF binary
  def self.call(svg_content)
    new(svg_content).convert!
  end

  def initialize(svg_content)
    @document = Nokogiri::XML(svg_content)
  end

  def convert!
    if svg_node.blank? || @document.errors.any?
      return nil
    end

    add_crop_marks!
    add_padding_and_margins!
    resize!
    add_watermark!

    self
  end

  def pdf
    @pdf ||= MiniMagick::Image.read(@document.to_s)
      .format("pdf")
      .to_blob
  end

  def svg
    @svg ||= @document.to_s
  end

  private

  def random_angle
    rand(-15..15)
  end

  def svg_node
    @document.at_css("svg")
  end

  def viewbox
    @viewbox ||= ViewBox.new(svg_node["viewBox"], PADDING, MARGIN)
  end

  def add_crop_marks!
    rectangle = build_rectangle_for_crop_marks(*viewbox.with_padding)

    svg_node.add_child(rectangle)
  end

  def add_padding_and_margins!
    svg_node["viewBox"] = viewbox.with_padding_and_margins.join(" ")
  end

  def build_rectangle_for_crop_marks(x, y, width, height)
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
    group = Nokogiri::XML::Node.new("g", @document)
    group["opacity"] = "0.25"
    group["transform"] = "translate(20, 20) rotate(#{random_angle}, 50, 25)"

    group.add_child(build_rectangle_for_watermark)
    group.add_child(build_text_for_watermark)

    svg_node.add_child(group)
  end

  def build_rectangle_for_watermark
    rect = Nokogiri::XML::Node.new("rect", @document)
    rect["x"] = "0"
    rect["y"] = "0"
    rect["width"] = "200"
    rect["height"] = "50"
    rect["rx"] = "10"
    rect["ry"] = "10"
    rect["fill"] = "grey"
    rect["stroke"] = "none"
    rect
  end

  def build_text_for_watermark
    text = Nokogiri::XML::Node.new("text", @document)
    text.content = WATERMARK_TEXT
    text["x"] = "100"
    text["y"] = "30"
    text["font-family"] = "Arial, sans-serif"
    text["font-size"] = "20"
    text["fill"] = "white"
    text["text-anchor"] = "middle"
    text["dominant-baseline"] = "middle"
    text
  end

  def resize!
    size = Size.new(svg_node["width"], svg_node["height"])
    svg_node["height"] = size.new_height
    svg_node["width"] = size.new_width
  end
end
