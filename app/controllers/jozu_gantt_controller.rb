# encoding: utf-8
#
# Jozu Gantt Plugin - JozuGanttController
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
class JozuGanttController < ApplicationController
  unloadable

  helper :watchers
  helper :issues

  include Redmine::Utils::DateCalculation

  before_filter :find_project
  before_filter :find_issues, :only => [:context_menu, :issue_edit]

  # 関連付けを担当者でやり直し
  def associate

    # 関連付けを削除
    beforeIssueRelationIds = relation_ids
    IssueRelation.delete_all(id: beforeIssueRelationIds)

    # 担当者ごとに関連付けを設定
    @project.members.each do |member|
      issues = Issue.find_by_sql(["select id, start_date, due_date from issues where assigned_to_id=:assigned_to_id and project_id=:project_id order by start_date, due_date, id", {:assigned_to_id => member.user_id, :project_id => @project.id}])
      if issues.present?
        issues.each_with_index do |issue, index|
          if index == 0
            next
          end

          begin
            delay = 0

            if issues[index].start_date > issues[index-1].due_date
              delay = working_days(issues[index-1].due_date, issues[index].start_date) - 2
            else
              delay = working_days(issues[index].start_date, issues[index-1].due_date) * -1
            end

            relation = IssueRelation.new
            relation.issue_from_id = issues[index-1].id
            relation.issue_to_id   = issues[index].id
            relation.delay         = delay
            relation.relation_type = "precedes"
            relation.save!
          rescue
          end
        end
      end
    end

    # ガントチャート画面にリダイレクト
    redirect_to :controller => 'gantts',
                :action => 'show',
                :project_id => @project
  end

  # 関連付けすべて削除
  def delete_relation

    # 関連付けを削除
    beforeIssueRelationIds = relation_ids
    IssueRelation.delete_all(id: beforeIssueRelationIds)

    # ガントチャート画面にリダイレクト
    redirect_to :controller => 'gantts',
                :action => 'show',
                :project_id => @project
  end

  # プロジェクトに設定されているすべての関連付けを取得
  def relation_ids
    return IssueRelation.find_by_sql(["select issue_relations.id from issue_relations inner join issues on issues.project_id=:project_id and (issue_relations.issue_from_id=issues.id or issue_relations.issue_to_id=issues.id)", {:project_id => @project.id}]);
  end

  # context_menu
  def context_menu
    if (@issues.size == 1)
      @issue = @issues.first
    end
    @issue_ids = @issues.map(&:id).sort

    @allowed_statuses = @issues.map(&:new_statuses_allowed_to).reduce(:&)

    @can = {:edit => User.current.allowed_to?(:edit_issues, @projects),
            :log_time => (@project && User.current.allowed_to?(:log_time, @project)),
            :copy => User.current.allowed_to?(:copy_issues, @projects) && Issue.allowed_target_projects.any?,
            :delete => User.current.allowed_to?(:delete_issues, @projects)
            }
    if @project
      if @issue
        @assignables = @issue.assignable_users
      else
        @assignables = @project.assignable_users
      end
      @trackers = @project.trackers
    else
      #when multiple projects, we only keep the intersection of each set
      @assignables = @projects.map(&:assignable_users).reduce(:&)
      @trackers = @projects.map(&:trackers).reduce(:&)
    end
    @versions = @projects.map {|p| p.shared_versions.open}.reduce(:&)

    @priorities = IssuePriority.active.reverse
    @back = back_url

    @options_by_custom_field = {}
    if @can[:edit]
      custom_fields = @issues.map(&:editable_custom_fields).reduce(:&).reject(&:multiple?)
      custom_fields.each do |field|
        values = field.possible_values_options(@projects)
        if values.present?
          @options_by_custom_field[field] = values
        end
      end
    end

    @safe_attributes = @issues.map(&:safe_attribute_names).reduce(:&)
    render :layout => false
  end

  def logger
    ::Rails.logger
  end

  # before filter
  def find_project
    if params[:project_id].present?
      @project = Project.find_by(identifier: params[:project_id])
    end
  end
end
