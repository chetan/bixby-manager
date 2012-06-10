
module ActiveRecord::Persistence

    # Updates the attributes of the model from the passed-in hash and saves the
    # record, all wrapped in a transaction. If the object is invalid, the saving
    # will fail and false will be returned.
    #
    # When updating model attributes, mass-assignment security protection is respected.
    # If no +:as+ option is supplied then the +:default+ role will be used.
    # If you want to bypass the protection given by +attr_protected+ and
    # +attr_accessible+ then you can do so using the +:without_protection+ option.
    #
    # @mod by chetan
    # If the passed attributes cause no change to the object, no save will occur.
    # This check *fails* if using nested parameters, therefore it's not currently
    # used
    def update_attributes(attributes, options = {})
      # The following transaction covers any possible database side-effects of the
      # attributes assignment. For example, setting the IDs of a child collection.
      self.assign_attributes(attributes, options)
      if self.changed? then
        with_transaction_returning_status do
          save
        end
      end
    end

end
