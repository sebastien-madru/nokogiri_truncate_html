require 'nokogiri_truncate_html/truncate_html_helper'

ActionView::Base.send :include, NokogiriTruncateHtml::TruncateHtmlHelper if defined? Rails
