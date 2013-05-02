# == Schema Information
#
# Table name: actions
#
#  id          :integer          not null, primary key
#  trigger_id  :integer          not null
#  action_type :integer          not null
#  target_id   :integer          not null
#  args        :text
#


class Action < ActiveRecord::Base

  if not const_defined? :Type then
    module Type
      ALERT = 1
      EXEC  = 2
    end
    Bixby::Util.create_const_map(Type)
    include Type
  end

  # Treat args as json and return parsed form
  #
  # @return [Object]
  def args_from_json
    begin
      return MultiJson.parse(self.args)
    rescue MultiJson::LoadError => ex
    end
    nil
  end

  def alert?
    self.action_type == Type::ALERT
  end

  def exec?
    self.action_type == Type::EXEC
  end

end
