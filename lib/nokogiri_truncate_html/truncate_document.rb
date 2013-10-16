require 'nokogiri'
require 'cgi'

module NokogiriTruncateHtml
  class TruncateFinished < Exception
  end

  class TruncateDocument < Nokogiri::XML::SAX::Document

    def initialize
      # We use the xhtml "flavour" so that we can decode
      # apostrophes. That is the only difference between
      # xhtml1 and html4.
      @encoder = HTMLEntities.new('xhtml1')
      @discard_first_element = false
    end

    def length=(length)
      @length = length
    end

    def omission=(omission)
      @omission = omission
    end

    def output
      while @tags.size > 0
        @output << "</#{@tags.pop}>"
      end
      @output
    end

    def start_document
      @output, @chars_remaining, @tags = '', @length, []
      @discard_first_element = false
    end

    def characters(string)
      text = @encoder.decode(string)
      @output << CGI.escapeHTML(text[0, @chars_remaining])
      @chars_remaining -= text.length
      if @chars_remaining < 0
        @output << @omission
        throw :truncate_finished
      end
    end

    def start_element(name, attrs = [])
      unless @discard_first_element
        return if %w(html body).include? name
        return @discard_first_element = true
      end

      if %w(br embed hr img input param).include? name
        @output << "<#{name}#{' ' if attrs.size > 0 }#{attrs.map { |attr,val| "#{attr}=\"#{val}\"" }.join(' ')} />"
      else
        @output << "<#{name}#{' ' if attrs.size > 0 }#{attrs.map { |attr,val| "#{attr}=\"#{val}\"" }.join(' ')}>"
        @tags.push name
      end
    end

    def end_element(name)
      @output << "</#{@tags.pop}>" if @tags.last == name
    end
  end
end
