
require 'terminal-table'

module Bixby
  module RailsExt


    # Adds the following helper methods to ActiveRecord:
    # * #describe
    # * #to_table
    #
    # `describe` can be used on the model class or an instance of a relation, e.g.
    # `User.describe` or `User.first.describe` or `User.where(...).describe`
    #
    # `to_table` can be used on any relation instance, e.g.
    # `User.first.to_table` or `User.all.to_table`, `User.where(...).to_table`
    #
    # In addition, to_table takes an optional boolean param to control truncation. When true
    # (the default), certain long column types will be truncated
    module ConsoleTable

      def self.puts_wide(str)
        if !Module.const_defined?(:Pry) then
          puts str
          return
        end

        Pry::Pager::PageTracker.wide_pages = true
        Pry::Helpers::BaseHelpers.stagger_output(str)
        Pry::Pager::PageTracker.wide_pages = false
      end

      def self.col_type(rows, col)
        rows.first.class.columns.find{ |c| c.name == col }.type.to_s
      end

      def self.to_table(rows, columns, truncate=false)
        table = Terminal::Table.new do |t|
          t.headings = columns.map{ |c| c.name }
          rows.each do |row|
            t << columns.map { |c|
              col = c.name
              val = row.send(col.to_sym)
              if truncate then
                if col =~ /_(key|token)$/ || col =~ /_?password$/ then
                  val = val.blank?() ? val : val[0,3] + "...[snip]"
                elsif %w{string text}.include? col_type(rows, col) then
                  if val.kind_of? Hash then
                    val = MultiJson.dump(val)
                  end
                  val = val.blank?() || val.length < 35 ? val : val[0,30] + "...[snip]"
                end
              end
              val
            }
          end
        end

        puts_wide(table.to_s)
        nil
      end

      module Relation
        # Dump all objects in this relation as a table
        def to_table(truncate=true)
          ConsoleTable.to_table(self.to_a, self.columns, truncate)
        end
      end # Relation

      module Base
        module ClassMethods
          # Dump the table description
          def describe
            table = Terminal::Table.new do |t|

              t.title = self.name
              t.headings = %w{Column Type SQL}

              self.columns.each { |c|
                type = [ "type=%s" % c.type ]
                type << ("limit=%s" % c.limit) if c.limit
                type << ("precision=%s" % c.precision) if c.precision
                type << ("null=%s" % c.null) if c.null
                t <<  [ c.name, type.join(", "), c.sql_type ]
              }
            end

            out = [] << table.to_s

            assoc = self.reflections.values.map do |ref|
              "#{ref.name} (#{ref.macro})"
            end

            out << ""
            out << "Associations: #{assoc.join(', ')}"
            out << ""

            ConsoleTable.puts_wide(out.join("\n"))
            nil

          end
        end

        module InstanceMethods
          # Dump this single object as a table
          def to_table(truncate=true)
            ConsoleTable.to_table([self], self.class.columns, truncate)
          end

          def describe
            self.class.describe
          end
        end
      end #  Base

    end
  end
end

module ActiveRecord
  class Relation
    include Bixby::RailsExt::ConsoleTable::Relation
  end
  class Base
    include Bixby::RailsExt::ConsoleTable::Base::InstanceMethods
    extend Bixby::RailsExt::ConsoleTable::Base::ClassMethods
  end
end

if Module.const_defined?(:Pry) then
  class Pry::Pager
    class PageTracker

      class << self
        attr_accessor :wide_pages
      end

      def page?
        # monkey patch to page if output is too wide
        @row >= @rows || (PageTracker.wide_pages && @col > @cols)
      end
    end
  end
end
