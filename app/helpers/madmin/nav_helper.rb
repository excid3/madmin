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
end
