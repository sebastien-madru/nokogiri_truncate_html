require 'active_support/core_ext/module/attribute_accessors.rb'
require 'nokogiri_truncate_html/truncate_document'

module NokogiriTruncateHtml
  module TruncateHtmlHelper
    mattr_accessor :parser
    mattr_accessor :document

    # you may set this to either 'html4', or 'xhtml1'
    mattr_accessor :flavor

    self.flavor = 'html4'

    # Truncates html respecting tags and html entities.
    #
    # The API is the same as ActionView::Helpers::TextHelper#truncate. It uses Nokogiri and HtmlEntities for entity awareness.
    #
    # Examples:
    #  truncate_html '<p>Hello <strong>World</strong></p>', :length => 7 # => '<p>Hello <strong>W&hellip;</strong></p>'
    #  truncate_html '<p>Hello &amp; Goodbye</p>', :length => 7          # => '<p>Hello &amp;&hellip;</p>'
    def truncate_html(input, *args)
      # support both 2.2 & earlier APIs
      options = args.extract_options!
      length = options[:length] || args[0] || 30
      omission = options[:omission] || args[1] || '&hellip;'

      # Adding div around the input is a hack. It gets removed in TruncateDocument.
      input = "<div>#{input}</div>"
      self.parser ||=
        begin
          self.document = TruncateDocument.new(TruncateHtmlHelper.flavor, length, omission)
          Nokogiri::HTML::SAX::Parser.new(document)
        end
      self.parser.parse_memory(input)
      self.document.output
    end
  end
end
