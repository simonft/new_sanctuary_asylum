class Activity < ActiveRecord::Base
  enum event: [:check_in, :master_calendar_hearing, :individual_hearing, :filing_asylum_application, :filing_work_permit, :detained]
  
  belongs_to :friend
  belongs_to :judge
  belongs_to :location
  has_many :accompaniements, dependent: :destroy
  has_many :volunteers, through: :accompaniements, source: :user

  validates :event, :occur_at, :location_id, :friend_id, presence: true

  def self.for_week(beginning_of_week:, end_of_week:, order:, events: Activity.events.keys)
    { dates: "#{beginning_of_week.strftime('%B %-d')} - #{(end_of_week - 2.days).strftime('%B %-d')}", 

      activities: Activity.where(event: events)
                          .where('occur_at >= ? AND occur_at <= ? ', beginning_of_week, end_of_week)
                          .order("occur_at #{order}").group_by {|activity| activity.occur_at.to_date } }
  end

  def self.upcoming_two_weeks
    activities = [ Activity.for_week(beginning_of_week: Date.today.beginning_of_week.beginning_of_day, 
                                     end_of_week: Date.today.end_of_week.end_of_day, 
                                     order: 'asc', 
                                     events: ['check_in', 'master_calendar_hearing', 'individual_hearing']) ]

    activities << Activity.for_week(beginning_of_week: 1.weeks.from_now.beginning_of_week, 
                                    end_of_week: 1.weeks.from_now.end_of_week, 
                                    order: 'asc',  
                                    events: ['check_in', 'master_calendar_hearing', 'individual_hearing'])
    activities
  end

  def self.current_month
    activities = [ Activity.for_week(beginning_of_week: Date.today.beginning_of_week, end_of_week: Date.today.end_of_week, order: 'asc') ]
    (1..4).each do |i|
      beginning_of_week = i.weeks.from_now.beginning_of_week
      end_of_week = i.weeks.from_now.end_of_week
      activities << Activity.for_week(beginning_of_week: beginning_of_week, end_of_week: end_of_week, order: 'asc')
    end
    activities
  end

  def self.last_month
    activities = []
    (1..5).each do |i|
      beginning_of_week = i.weeks.ago.beginning_of_week
      end_of_week = i.weeks.ago.end_of_week
      activities << Activity.for_week(beginning_of_week: beginning_of_week, end_of_week: end_of_week, order: 'desc')
    end
    activities
  end
end
