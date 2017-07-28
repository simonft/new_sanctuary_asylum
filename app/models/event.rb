class Event < ActiveRecord::Base

  belongs_to :location

  def self.start_time_decending
  end

end
