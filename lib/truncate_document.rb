require 'nokogiri'

class TruncateDocument < Nokogiri::XML::SAX::Document
  def initialize(flavor='html4', length, omission)
    @encoder = HTMLEntities.new(flavor)
    @length, @omission = length, omission
    @discard_first_element = false
  end

  def output
    @output
  end

  def start_document
    @output, @chars_remaining, @tags = '', @length, []
    @discard_first_element = false
  end

  def characters(string)
    return if @chars_remaining < 0
    text = @encoder.decode(string)
    if text.length <= @chars_remaining
      @output << @encoder.encode(text)
    else
      @output << @encoder.encode(text[0, @chars_remaining])
    end
    @chars_remaining -= text.length
    @output << @omission if @chars_remaining < 0
  end

  def start_element(name, attrs = [])
    return if %w(html body).include? name
    return @discard_first_element = true unless @discard_first_element
    return if @chars_remaining <= 0
    @output << tag_to_string(name, attrs)
    @tags.push name unless self_closing?(name)
  end

  def end_element(name)
    @output << "</#{@tags.pop}>" if @tags.last == name
  end

  private
  def tag_to_string(name, attrs)
    "<#{name}#{' ' if attrs.size > 0}#{attrs.map { |attr,val| "#{attr}=\"#{val}\"" }.join(' ')}#{' /' if self_closing?(name)}>"
  end

  def self_closing?(name)
    %w(br embed hr img input param).include? name
  end
end
