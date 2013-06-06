require 'truncate_html_helper'

if defined?(ActionView::Base)
  ActionView::Base.send :include, TruncateHtmlHelper
end
