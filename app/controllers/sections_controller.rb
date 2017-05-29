class SectionsController < ApplicationController
  before_action :set_section, only: [:show, :edit, :update, :destroy, :email_event_request_to_staff]

  def assign_instructor_to_section
    puts "the params are #{params}"
    @instructor = Instructor.find(params[:instructor_id])
    @section = Section.find(params[:section_id])
    @section.instructor_id = @instructor.id
    @section.instructor_status = "Assigned"    
    @section.save!
    # @section.event.update_status
    redirect_to :back   
  end

  def unassign_instructor_from_section
    puts "the params are #{params}"
    @section = Section.find(params[:section_id])
    @section.instructor_id = nil
    @section.instructor_status = "Unassigned"    
    @section.save!
    redirect_to :back   
  end

  def confirm_instructor
    puts "the params are #{params}"
    @section = Section.find(params[:section_id])
    @section.instructor_status = "Confirmed"    
    @section.save!
    @section.event.update_status
    LessonMailer.staff_confirmation_for_event(@section).deliver
    redirect_to :back, notice: "Thank you. Your confirmation for this event has been received."
  end

  def cancel_instructor
    puts "the params are #{params}"
    @section = Section.find(params[:section_id])
    @section.instructor_status = "Canceled"    
    @section.instructor_id = nil
    @section.save!
    @section.event.update_status
    redirect_to :back   
  end

  def decline_instructor
    @section = Section.find(params[:section_id])
    @instructor = @section.instructor
    @section.instructor_status = "Declined"    
    @section.instructor_id = nil
    @section.save!
    @section.event.update_status
    LessonMailer.staff_declined_event(@section,@instructor).deliver
    redirect_to :back   
  end

  def email_event_request_to_staff
    LessonMailer.email_event_request_to_staff(@section).deliver
    redirect_to events_path, notice: "Email successfully sent to #{@section.instructor.contact_email}."
  end

  # GET /sections
  # GET /sections.json
  def index
    @sections = Section.all
  end

  # GET /sections/1
  # GET /sections/1.json
  def show
  end

  # GET /sections/new
  def new
    @section = Section.new
  end

  # GET /sections/1/edit
  def edit
  end

  # POST /sections
  # POST /sections.json
  def create
    @section = Section.new(section_params)

    respond_to do |format|
      if @section.save
        format.html { redirect_to "/schedule-filtered?utf8=✓&search_date=#{@section.parametized_date}&age_type=#{@section.age_group}", notice: 'Section was successfully created.' }
        format.json { render :show, status: :created, location: @section }
      else
        format.html { render :new }
        format.json { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sections/1
  # PATCH/PUT /sections/1.json
  def update
    respond_to do |format|
      if @section.update(section_params)
        # format.html { redirect_to @section.event, notice: 'Section was successfully updated.' }
        format.html { redirect_to events_path, notice: 'Section was successfully updated.' }
        format.json { render :show, status: :ok, location: @section }
      else
        format.html { render :edit }
        format.json { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sections/1
  # DELETE /sections/1.json
  def destroy
    @section.destroy
    respond_to do |format|
      format.html {     redirect_to "/schedule-filtered?utf8=✓&search_date=#{@section.parametized_date}&age_type=#{@section.age_group}", notice: 'Section was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_section
      @section = Section.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def section_params
      params.require(:section).permit(:age_group, :instructor_id, :instructor_status, :level, :sport_id, :capacity, :lesson_type, :date, :name, :shift_id)
    end
end
