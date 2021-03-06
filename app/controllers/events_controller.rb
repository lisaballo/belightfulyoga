class EventsController < ApplicationController
  before_filter :initialize_page
  
  def index
    @events = Event.where('(start_date IS NOT NULL AND end_date IS NULL AND start_date >= ?) OR (start_date IS NOT NULL AND end_date IS NOT NULL AND end_date >= ?) OR start_date IS NULL', Date.today, Date.today).order(:start_date)
    
  end
  
private

  def initialize_page
    @page = Page.friendly.find('current-events')
    @page.page_parts.each do |pp|
      instance_variable_set "@#{pp.title.gsub(' ', '_').downcase}", @page.page_part_placements.find_by_page_part_id(pp.id)
    end
  end
  
end
