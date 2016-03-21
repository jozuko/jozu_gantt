# Jozu Gantt Plugin - lib/redmine/helpers/gantt.rbの拡張
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


module JozuGantt::GanttPatch
  def self.included(base) # :nodoc:

    base.class_eval do

      # initialize -> jozu_gantt_initialize
      def initialize_with_jozu_gantt_initialize(options={})
        initialize_without_jozu_gantt_initialize(options)
        @assign_data = ''

        @project_temp = Project.find_by(identifier: options[:project_id])
        if @project_temp.present?
          unless options[:months].nil?
            @jozu_gantt_project_settings = JozuGanttProjectSettings.find_or_create(@project_temp.id)
            @jozu_gantt_project_settings.show_assign = options[:show_extra_column_assign_to]
            @jozu_gantt_project_settings.save
          end
        end
      end

      # render_object_row -> jozu_gantt_render_object_row
      def render_object_row_with_jozu_gantt_render_object_row(object, options)
        class_name = object.class.name.downcase
        send("subject_for_#{class_name}", object, options) unless options[:only] == :lines
        send("assign_for_#{class_name}", object, options) unless options[:only] == :lines
        send("line_for_#{class_name}", object, options) unless options[:only] == :subjects
        options[:top] += options[:top_increment]
        @number_of_rows += 1
        if @max_rows && @number_of_rows >= @max_rows
          raise MaxLinesLimitReached
        end
      end

      # html_subject -> jozu_gantt_html_subject
      def html_subject_with_jozu_gantt_html_subject(params, subject, object)
        style = "position: absolute;top:#{params[:top]}px;left:#{params[:indent]}px;"
        style << "width:#{params[:subject_width] - params[:indent]}px;" if params[:subject_width]
        content = html_subject_content(object) || subject
        tag_options = {:style => style}
        tr_tag_options = {}
        case object
        when Issue
          tag_options[:id] = "issue-#{object.id}"
          tag_options[:class] = "issue-subject"
          tag_options[:title] = object.subject
          tr_tag_options[:class] = "hascontextmenu"
        when Version
          tag_options[:id] = "version-#{object.id}"
          tag_options[:class] = "version-name"
        when Project
          tag_options[:class] = "project-name"
        end
        output = view.content_tag('table', view.content_tag('tr', view.content_tag('td', view.content_tag(:div, content, tag_options)), tr_tag_options))
        @subjects << output
        output
      end

      # html_subject_content -> jozu_html_subject_content
      def html_subject_content_with_jozu_html_subject_content(object)
        case object
        when Issue
          html_issue_content(object)
        when Version
          html_subject_content_without_jozu_html_subject_content(object)
        when Project
          html_subject_content_without_jozu_html_subject_content(object)
        end
      end

      # alias_method_chain
      alias_method_chain :initialize,           :jozu_gantt_initialize
      alias_method_chain :render_object_row,    :jozu_gantt_render_object_row
      alias_method_chain :html_subject,         :jozu_gantt_html_subject
      alias_method_chain :html_subject_content, :jozu_html_subject_content

      # Renders the subjects of the Gantt chart, the left side.
      def assign_data(options={})
        @assign_data
      end

      # no display
      def assign_for_project(project, options)
      end

      # no display
      def assign_for_version(version, options)
      end

      # assign_to display
      def assign_for_issue(issue, options)
        send "#{options[:format]}_assign", options, issue
      end

      # display for assign_to
      def html_assign(params, issue)
        css_classes = ''
        s = "".html_safe
        if issue.assigned_to.present?
          style = "position: absolute;top:#{params[:top]}px;left:4px;"
          style << "width:#{params[:assign_width]}px;" if params[:assign_width]
          style << "width:130px;" unless params[:assign_width]
          s << view.link_to_user(issue.assigned_to).html_safe
          assign = view.content_tag(:span, s, :class => css_classes).html_safe
          output = view.content_tag(:div,
                                    assign,
                                    :class => "issue-assign",
                                    :style => style,
                                    :title => issue.assigned_to.name,
                                    :id => "user-#{issue.id}")
          @assign_data << output
          output
        end
      end

      def pdf_assign(params, issue)
      end

      def image_assign(params, issue)
      end

      def getHolidays(from_date, to_date)
        jozu_holidays = []

        date = from_date
        while date <= to_date do
          jozu_holidays << date if next_working_date(date) != date
          date += 1
        end

        return jozu_holidays
      end

      # issue content
      def html_issue_content(issue)
          s = "".html_safe

          css_classes = ''
          if issue.closed?
            css_classes << ' issue-closed' if issue.closed?
          else
            css_classes << ' issue-overdue' if issue.overdue?
            css_classes << ' issue-behind-schedule' if issue.behind_schedule?
            css_classes << ' issue-on-schedule' unless issue.behind_schedule? || issue.overdue?
          end
          css_classes << ' icon icon-issue' unless Setting.gravatar_enabled? && issue.assigned_to

          if issue.start_date && issue.due_before && issue.done_ratio
            progress_date = calc_progress_date(issue.start_date,
                                               issue.due_before, issue.done_ratio)
            css_classes << ' behind-start-date' if progress_date < self.date_from
            css_classes << ' over-end-date' if progress_date > self.date_to
          end
          s << text_to_issue(issue).html_safe

          content = "".html_safe
          content << view.check_box_tag("ids[]", issue.id, false, :id => nil, :style => "display:none;")
          content << view.content_tag(:span, s, :class => css_classes).html_safe
          content.html_safe
      end

      # Displays a text to +issue+ with its subject.
      def text_to_issue(issue, options={})
        title = nil
        subject = nil
        text = options[:tracker] == false ? "##{issue.id}" : "#{issue.tracker} ##{issue.id}"
        if options[:subject] == false
          title = issue.subject.truncate(60)
        else
          subject = issue.subject
          if truncate_length = options[:truncate]
            subject = subject.truncate(truncate_length)
          end
        end
        only_path = options[:only_path].nil? ? true : options[:only_path]
        s = text
        s << h(": #{subject}") if subject
        s = h("#{issue.project} - ") + s if options[:project]
        s
      end

    end
  end

  def logger
    ::Rails.logger
  end
end

unless Redmine::Helpers::Gantt.include? JozuGantt::GanttPatch
  Redmine::Helpers::Gantt.send(:include, JozuGantt::GanttPatch)
end

