# encoding: utf-8
#
# Jozu Gantt Plugin - JozuGanttProjectSettings
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
class JozuGanttProjectSettings < ActiveRecord::Base

  ALL_PROJECT = -1
  ALL_PROJECT.freeze

  def self.find_or_create(project_id)
    jozu_gantt_settings = JozuGanttProjectSettings.where(['project_id = ?', project_id]).first()

    unless jozu_gantt_settings.present?
      if project_id != ALL_PROJECT
        jozu_gantt_settings = JozuGanttProjectSettings.where(['project_id = ?', ALL_PROJECT]).first()
      end
      jozu_gantt_settings = JozuGanttProjectSettings.new unless jozu_gantt_settings.present?

      jozu_gantt_settings.project_id    = project_id
      jozu_gantt_settings.show_assign   = 1
      jozu_gantt_settings.subject_width = 200
      jozu_gantt_settings.assign_width  = 100

      jozu_gantt_settings.save!
    end

    return jozu_gantt_settings
  end

  def logger
    ::Rails.logger
  end

end
