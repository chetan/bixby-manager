
module ActiveRecord::Persistence

    # Updates the attributes of the model from the passed-in hash and saves the
    # record, all wrapped in a transaction. If the object is invalid, the saving
    # will fail and false will be returned.
    #
    # @mod by chetan
    # If the passed attributes cause no change to the object, no save will occur.
    # This check *fails* if using nested parameters, therefore it's not currently
    # used
    def update_attributes(attributes)
      # The following transaction covers any possible database side-effects of the
      # attributes assignment. For example, setting the IDs of a child collection.
      self.assign_attributes(attributes)
      if self.changed? then
        with_transaction_returning_status do
          save
        end
      end
    end

end
