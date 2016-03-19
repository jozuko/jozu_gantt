Dir[File.expand_path('../lib/jozu_gantt', __FILE__) << '/*.rb'].each do |file|
  require_dependency file
end
Dir[File.expand_path('../lib/jozu_gantt/hooks', __FILE__) << '/*.rb'].each do |file|
  require_dependency file
end

Redmine::Plugin.register :jozu_gantt do
  name 'Jozu Gantt plugin'
  author 'Jozuko'
  description 'Gantt plugin for redmine 3.2'
  version '1.0.0'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  menu :admin_menu, :setting_jozu_gantt, {
                      :controller => 'jozu_gantt_settings',
                      :action => 'index'
                    },
                    :caption => 'jozu_gantt',
                    :last => true

  menu :project_menu, :project_setting_jozu_gantt, {
                        :controller => 'jozu_gantt_settings',
                        :action => 'project_index'
                      },
                      :caption => 'jozu_gantt',
                      :last => true,
                      :param => :project_id

  permission :jozu_gantt, {
      :jozu_gantt_settings => [ :index, :project_index ]
  },
  :public => true

end
