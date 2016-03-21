# Jozu Gantt Plugin - init.rb
#
# The MIT License (MIT)
#
# Copyright (c) [2016] [jozuko]
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
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
