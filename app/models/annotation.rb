
class Annotation < ActiveRecord::Base

  belongs_to :host
  acts_as_taggable # adds :tags accessor

end
