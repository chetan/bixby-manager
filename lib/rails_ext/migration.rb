
module Bixby::ARTableMigration

  # Create column of type 'char'
  def char(*args)
    opts = args.extract_options!
    type = @base.type_to_sql(:string, opts.delete(:limit), opts.delete(:precision), opts.delete(:scale)) rescue type
    type = type.to_s.gsub(/varchar/, 'char')
    args.each do |col|
      self.column(col, type, opts)
    end
  end
end

class ActiveRecord::Migration
end

class ActiveRecord::ConnectionAdapters::TableDefinition
  include Bixby::ARTableMigration
end

class ActiveRecord::ConnectionAdapters::Table
  include Bixby::ARTableMigration
end
