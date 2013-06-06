
class Railtie < Rails::Railtie
  initializer "initialize_truncate_html" do
    ActionView::Base.send :include, TruncateHtmlHelper
  end
end
