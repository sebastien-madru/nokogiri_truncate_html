require 'active_support/core_ext/module/attribute_accessors.rb'
require 'active_support/core_ext/string/output_safety'
require 'nokogiri_truncate_html/truncate_document'

module NokogiriTruncateHtml
  module TruncateHtmlHelper
    mattr_accessor :parser
    mattr_accessor :document

    # Truncates html respecting tags and html entities.
    #
    # The API is the same as ActionView::Helpers::TextHelper#truncate. It uses Nokogiri and HtmlEntities for entity awareness.
    #
    # Examples:
    #  truncate_html '<p>Hello <strong>World</strong></p>', :length => 7 # => '<p>Hello <strong>W&hellip;</strong></p>'
    #  truncate_html '<p>Hello &amp; Goodbye</p>', :length => 7          # => '<p>Hello &amp;&hellip;</p>'
    def truncate_html(input, *args)
      self.document ||= TruncateDocument.new#(TruncateHtmlHelper.flavor) #, length, omission)
      self.parser ||= Nokogiri::HTML::SAX::Parser.new(document)

      # support both 2.2 & earlier APIs
      options = args.extract_options!
      length = options[:length] || args[0] || 30
      omission = options[:omission] || args[1] || '&hellip;'

      # Adding div around the input is a hack. It gets removed in TruncateDocument.
      input = "<div>#{input}</div>"
      self.document.length = length
      self.document.omission = omission
      begin
        self.parser.parse_memory(input)
      rescue TruncateFinished
      end
      self.document.output.html_safe
    end
  end
end
