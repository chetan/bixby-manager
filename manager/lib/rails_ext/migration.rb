
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
      opts[:null] = false
      self.column(col, type, opts)
    end
  end

  # Override integer method to create unsigned ints by default.
  # To get a signed int, pass { :unsigned => false }
  def integer(*args)
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
  # @param [String] table         table on which to add the constraint
  # @param [Stirng] other_table   table to which we will refer
  def add_fk(table, other_table)
    fk_name = "fk_#{table}_#{other_table.to_s.pluralize}"
    o_fk = other_table.to_s.foreign_key
    add_index table, o_fk, :order => { o_fk => :asc }
    execute "ALTER TABLE #{table} ADD CONSTRAINT `#{fk_name}` FOREIGN KEY (`#{other_table.to_s.foreign_key}` ) REFERENCES `#{other_table.to_s.pluralize}` (`id` ) ON DELETE NO ACTION ON UPDATE NO ACTION"
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
