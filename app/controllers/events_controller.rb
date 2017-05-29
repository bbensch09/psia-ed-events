class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :set_week_start_monday  
  skip_before_action :authenticate_user!

  def email_all_staff
    staff_to_email = Instructor.all.to_a.keep_if{|i| i.sections.count > 0 }
    staff_to_email.each do |instructor|
      LessonMailer.email_full_schedule(instructor).deliver
    end
    redirect_to events_path, notice: "Email successfully sent to all instructors"
  end


  def assign_all_remaining_events
    Event.assign_all_remaining_events
    @events = Event.all.sort_by { |event| event.start_time}
    render 'index'
  end

  def unassign_all_events
    Event.unassign_all_events
    @events = Event.all.sort_by { |event| event.start_time}
    render 'index'
  end

  def review_events
    if current_instructor = Instructor.find_by(contact_email: current_user.email)
      @events = Event.joins(:sections).where(sections: { instructor_id: current_instructor.id})
      @events = @events.sort_by { |event| event.start_time}
    elsif current_user.email == "brian@snowschoolers.com" || current_user.email == "bschilling@skihomewood.com"
      @events = Event.all.sort_by { |event| event.start_time}
    end
    respond_to do |format|
          format.html
          format.csv { send_data @events_to_csv.to_csv, filename: "events-#{Date.today}.csv" }
          format.xls
    end
    render 'index'
  end

  def index_to_be_scheduled
      Event.evaluate_all_events
      @events = Event.where(status: "New Event")
      @events = @events.sort_by { |event| event.start_time}
      render 'index'
  end

  def index_to_be_confirmed
      Event.evaluate_all_events
      @events = Event.where(status: "Staff Assigned")
      @events = @events.sort_by { |event| event.start_time}
      render 'index'
  end
  # GET /events
  # GET /events.json
  def index   
    Event.evaluate_all_events
    @events = Event.all.sort_by { |event| event.id}
    @events_to_csv = Event.all
    respond_to do |format|
          format.html
          format.csv { send_data @events_to_csv.to_csv, filename: "events-#{Date.today}.csv" }
          format.xls
    end
  end

  def import
   Event.import(params[:file])
   redirect_to events_path, notice: "New events data successfully imported."
  end

  def delete_all
    Event.delete_all
    Section.delete_all
    redirect_to events_path, notice: "All events have been deleted."
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to events_path, notice: 'event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to events_path, notice: 'event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:start_time, :end_time, :date, :name, :instructor_status, :instructor_id, :category, :staff_level, :length_in_days, :sport_id, :location_id, :capacity, :event_id)
    end

    def set_week_start_monday
      config.beginning_of_week = :monday
    end
end
