# Jozu Gantt Plugin - app/models/issue_relation.rbの拡張
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

module JozuGantt::IssueRelationPatch

  include Redmine::Utils::DateCalculation

  def self.included(base) # :nodoc:
    base.class_eval do

      # successor_soonest_start -> jozu_successor_soonest_start
      def successor_soonest_start_with_jozu_successor_soonest_start
        if (IssueRelation::TYPE_PRECEDES == self.relation_type) && delay && issue_from && (issue_from.start_date || issue_from.due_date)
          if delay < 0
            add_working_days((issue_from.due_date || issue_from.start_date), (1 + delay))
          else
            add_working_days((issue_from.due_date || issue_from.start_date), (2 + delay))
          end
        end
      end

      # alias_method_chain
      alias_method_chain :successor_soonest_start, :jozu_successor_soonest_start

      def logger
        ::Rails.logger
      end

    end
  end
end

unless IssueRelation.include? JozuGantt::IssueRelationPatch
  IssueRelation.send(:include, JozuGantt::IssueRelationPatch)
end
