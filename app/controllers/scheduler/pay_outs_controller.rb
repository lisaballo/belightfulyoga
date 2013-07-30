class Scheduler::PayOutsController < Scheduler::ApplicationController
  
  helper_method :start_date, :end_date 
  
  def index
    @pay_outs = PayOut.where('paid_date is not null')
    @pay_outs = @pay_outs.where('pay_outs.teacher_id = ?', teacher) unless teacher.blank?
    @pay_outs = @pay_outs.where('start_date >= ?', start_date)
    @pay_outs = @pay_outs.where('end_date <= ?', end_date)
    @pay_outs = @pay_outs.order(sort_column + " " + sort_direction)
  end
  
  def unpaid
    @pay_outs = PayOut.where(:paid_date => nil)
    @pay_outs = @pay_outs.where('pay_outs.teacher_id = ?', teacher) unless teacher.blank?
  end
  
  def new
    @pay_out = PayOut.new(:end_date => Date.today, :start_date => 30.days.ago)
  end
  
  def create
    if params[:pay_out][:teacher_id].blank?
      @teachers = Teacher.all
    else
      @teachers = Teacher.where(:id => params[:pay_out][:teacher_id])
    end
    
    @teachers.each do |teacher|
      events = teacher.course_events.where('event_date >= ? AND event_date <= ?', params[:pay_out][:start_date], params[:pay_out][:end_date]).where(:paid => nil)
      unless events.empty?
        total = 0.to_d
        events.each do |event|
          total += event.total_pay_out
        end
        teacher.pay_outs.create(:start_date => params[:pay_out][:start_date], :end_date => params[:pay_out][:end_date], :calculated_pay_out => total)
      end
    end
    
    flash[:success] = "Pay Outs created"
    redirect_to unpaid_scheduler_pay_outs_path
  end
  
  def show
    @pay_out = PayOut.find(params[:id])
    @events = @pay_out.events
  end
  
  def update
    @pay_out = PayOut.find(params[:id])
    if @pay_out.update_attributes(params[:pay_out])
      flash[:success] = "Pay out updated"
      redirect_to [:scheduler, @pay_out]
    else
      render 'show'
    end
  end
  
private

  def end_date
    params[:end_date] ||= Date.today
  end
  
  def start_date
    params[:start_date] ||= 60.days.ago
  end
  
end