
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


end

class ActiveRecord::ConnectionAdapters::TableDefinition

  # create an 'int(10) unsigned' id field
  #
  # @param [String] col     column name (default = :id)
  def add_id(col = :id)
    self.column col, "int(10) unsigned", :null => false
  end

end
