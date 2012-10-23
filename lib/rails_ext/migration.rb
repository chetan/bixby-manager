
module Bixby::ARTableMigration
  # create an 'int(10) unsigned' id field
  #
  # @param [String] col     column name (default = :id)
  def add_id(col = :id, opts = {})
    primary = opts.delete(:primary) || col.to_s == "id"
    type = "INT(10) UNSIGNED"
    type = "#{type} AUTO_INCREMENT PRIMARY KEY" if primary

    if opts[:polymorphic] then
      opts[:null] = true
      col_id = col.to_s =~ /_id$/ ? col : col.to_s + "_id"
      col_type = col.to_s =~ /_id$/ ? col.to_s.gsub(/_id/, '_type') : col.to_s + "_type"
      self.column(col_id, type, opts)
      self.column(col_type, "string", opts)
    else
      opts[:null] = (col == :parent_id) if not opts.include? :null
      self.column(col, type, opts)
    end
  end

  # Override integer method to create unsigned ints by default.
  # To get a signed int, pass { :unsigned => false }
  def int(*args)
    opts = args.extract_options!
    type = @base.type_to_sql(:integer, opts.delete(:limit), opts.delete(:precision), opts.delete(:scale)) rescue type
    unsigned = opts.include?(:unsigned) ? opts[:unsigned] : true # unsigned by default
    type = "#{type} UNSIGNED" if unsigned
    args.each do |col|
      self.column(col, type, opts)
    end
  end

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

  # Add a foreign key constraint to a table
  #
  # @param [Symbol] table         table on which to add the constraint
  # @param [Symbol] other_table   table to which we will refer
  # @param [Symbol] column        column in 'table' if it differs from 'other_table_id' (default: nil)
  def add_fk(table, other_table, column = nil)

    if other_table == :parent or other_table == :parent_id then
      # self reference
      fk_name = "fk_#{table}_parent_id"
      add_index table, "parent_id", :order => { "parent_id" => :asc }
      execute "ALTER TABLE #{table} ADD CONSTRAINT `#{fk_name}` FOREIGN KEY (`parent_id`) REFERENCES `#{table}` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION"

    else
      # standard fk
      fk_name = "fk_#{table}_#{other_table.to_s.pluralize}"
      fk_col = column || other_table.to_s.foreign_key
      add_index table, fk_col, :order => { fk_col => :asc }
      execute "ALTER TABLE #{table} ADD CONSTRAINT `#{fk_name}` FOREIGN KEY (`#{fk_col}` ) REFERENCES `#{other_table.to_s.pluralize}` (`id` ) ON DELETE NO ACTION ON UPDATE NO ACTION"
    end
  end

  def drop_fk(table, fk)
    execute "ALTER TABLE #{table} DROP FOREIGN KEY #{fk};"
  end

  # create an 'int(10) unsigned' id field
  #
  # @param [String] col     column name (default = :id)
  def add_id(table, col = :id, opts = {})
    primary = opts.delete(:primary) || col.to_s == "id"
    type = "INT(10) UNSIGNED"
    type = "#{type} AUTO_INCREMENT PRIMARY KEY" if primary
    opts[:null] = false
    self.add_column(table, col, type, opts)
  end

end

class ActiveRecord::ConnectionAdapters::TableDefinition
  include Bixby::ARTableMigration
end

class ActiveRecord::ConnectionAdapters::Table
  include Bixby::ARTableMigration
end
