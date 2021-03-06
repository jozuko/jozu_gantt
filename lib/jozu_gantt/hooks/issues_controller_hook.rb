# encoding: utf-8
#
# Jozu Gantt Plugin - IssuesControllerHook
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
class IssuesControllerHook < Redmine::Hook::ViewListener

  include Redmine::Utils::DateCalculation

  # Context:
  # * :issue => Issue being saved
  # * :params => HTML parameters
  #
  def controller_issues_bulk_edit_before_save(context={})
    params = context[:params]
    new_issue = context[:issue]

    return '' unless params[:issue]['start_date'].present?

    # チケットの直前の状態を取得
    old_issue = Issue.find(new_issue.id)

    # チケット開始日/期日を取得
    new_start_date = next_working_date(new_issue.start_date)
    new_due_date = update_due_date(new_start_date, old_issue)

    # 開始日を操作するとdelayがおかしくなるため、関連付けを削除する
    # ちなみにdelayをいじるとissueの更新が走るため、コンフリクトしてしまう。
    @issue_relations = IssueRelation.where("issue_to_id = ? and relation_type = ?", new_issue.id, 'precedes')
    @issue_relations.each do |issue_relation|
      from_date = issue_relation.issue_from.due_date
      from_date = issue_relation.issue_from.start_date unless from_date.present?
      unless from_date.present?
        issue_relation.destroy
        next
      end

      to_date = new_start_date
      if to_date > from_date
        issue_relation.delay = working_days(from_date, to_date) - 2
      else
        issue_relation.delay = working_days(to_date, from_date) * -1
      end
      issue_relation.save
    end

    new_issue.reload
    new_issue.start_date = new_start_date
    new_issue.due_date = new_due_date

    return ''
  end

  def update_due_date(new_start_date, old_issue)

    # 稼働日数を取得
    issue_working_days = 1
    if old_issue.start_date.present? && old_issue.due_date.present?
      old_start_date = old_issue.start_date
      old_due_date = old_issue.due_date
      issue_working_days = working_days(old_start_date, old_due_date)
    end

    # 開始日＋稼働日収で期限を算出
    add_working_days(new_start_date, issue_working_days)
  end

  def logger
    ::Rails.logger
  end
end
