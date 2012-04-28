
class Resource < ActiveRecord::Base

  belongs_to :host
  has_one :check
  has_one :command, :through => :check

  def metrics(time_start=nil, time_end=nil, tags = {}, agg = "sum", downsample = nil)
    time_start = Time.new - 86400 if time_start.nil?
    time_end = Time.new if time_end.nil?
    tags ||= {}
    agg ||= "sum"

    Metrics.new.get_for_check(self.check, time_start, time_end, tags, agg, downsample)
  end

end
