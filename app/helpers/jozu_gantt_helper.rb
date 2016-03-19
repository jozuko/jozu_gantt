module JozuGanttHelper

  def context_menu_link(name, url, options={})
    options[:class] ||= ''
    if options.delete(:selected)
      options[:class] << ' icon-checked disabled'
      options[:disabled] = true
    end
    if options.delete(:disabled)
      options.delete(:method)
      options.delete(:data)
      options[:onclick] = 'return false;'
      options[:class] << ' disabled'
      url = '#'
    end
    link_to h(name), url, options
  end

end
