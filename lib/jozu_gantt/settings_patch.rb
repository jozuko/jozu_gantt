# Jozu Gantt Plugin - app/models/setting.rbの拡張
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

module JozuGantt::SettingPatch
  def self.included(base) # :nodoc:
    base.class_eval do

      after_save :update_non_working_week_days

      @@non_working_week_days_cache = nil

      def update_non_working_week_days
        @@non_working_week_days_cache = nil
      end

      def self.find_non_working_week_days
        unless @@non_working_week_days_cache.present?
          @@non_working_week_days_cache = Setting.non_working_week_days
        end

        return @@non_working_week_days_cache
      end

      def logger
        ::Rails.logger
      end

    end
  end
end

unless Setting.include? JozuGantt::SettingPatch
  Setting.send(:include, JozuGantt::SettingPatch)
end
