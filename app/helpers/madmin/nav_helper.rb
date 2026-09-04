module Madmin::NavHelper
  def nav_link_to(name = nil, options = {}, html_options = {}, &block)
    if block
      html_options = options
      options = name
      name = block
    end

    url = url_for(options)
    starts_with = html_options.delete(:starts_with)
    html_options[:class] = Array.wrap(html_options[:class])
    active_class = html_options.delete(:active_class) || "active"
    inactive_class = html_options.delete(:inactive_class) || ""

    active = if (paths = Array.wrap(starts_with)) && paths.present?
      paths.any? { |path| request.path.start_with?(path) }
    else
      request.path == url
    end

    classes = active ? active_class : inactive_class
    html_options[:class] << classes unless classes.empty?

    html_options.except!(:class) if html_options[:class].empty?

    return link_to url, html_options, &block if block

    link_to name, url, html_options
  end

  # label default is model i18n_key, is a Symbol
  def menu_label(label)
    if label.is_a?(Symbol)
      I18n.t("activerecord.models.#{label}", default: [:"madmin.navigation.#{label}", label.to_s.pluralize(I18n.locale).titleize])
    else
      label
    end
  end
end
