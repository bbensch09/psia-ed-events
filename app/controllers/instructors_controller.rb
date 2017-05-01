class InstructorsController < ApplicationController
  before_action :set_instructor, only: [:show, :edit, :update, :destroy, :show_candidate]
  before_action :confirm_admin_permissions, except: [:create, :update, :new, :edit, :show, :thank_you, :browse, :show, :show_candidate]
  # before_action :confirm_user_permissions, only: [:edit, :update]
  skip_before_action :authenticate_user!, only: [:new, :create, :thank_you, :browse, :show, :show_candidate]


  def import
   Instructor.import(params[:file])
   redirect_to instructors_path, notice: "New instructors data successfully imported."
  end

  def delete_all
    Instructor.delete_all
    redirect_to instructors_path, notice: "All instructors have been deleted."
  end


  def verify
    instructor = Instructor.find(params[:id])
    instructor.status = 'Active'
    instructor.save
    LessonMailer.instructor_status_activated(instructor).deliver
    redirect_to instructors_path, notice: "Instructor has been verified"
  end

  def revoke
    instructor = Instructor.find(params[:id])
    instructor.status = "Revoked"
    instructor.save
    redirect_to instructors_path, notice: "Instructor privileges have been revoked"
  end

  # GET /instructors
  # GET /instructors.json
  def index
      @instructors = Instructor.all#.sort {|a,b| b.primary_location_ids <=> a.primary_location_ids}
      respond_to do |format|
          format.html
          format.csv { send_data @instructors.to_csv, filename: "instructors-PSIA-#{Date.today}.csv" }
          format.xls
        end
  end

  def admin_index
     @instructors = Instructor.all.sort {|a,b| a.id <=> b.id}
  end

  # GET /browse
  # GET /browse.json
  def browse
    puts "Session values stored: #{session[:lesson]}"
    @instructors = Instructor.where(status: "Active")
    @instructors = @instructors.to_a.keep_if {|instructor| instructor.ski_levels.any? || instructor.snowboard_levels.any? }
    @instructors.sort! {|a,b| b.reviews.count <=> a.reviews.count}
  end

  # GET /instructors/1
  # GET /instructors/1.json
  def show
  end

  def show_candidate
  end

  # GET /instructors/new
  def new
    if current_user.instructor
      @instructor = current_user.instructor
      @instructor_id = Instructor.find(params[:id]).user_id
      render 'edit'
      else
      @instructor = Instructor.new
      @instructor_id = nil
    end

  end

  # GET /instructors/1/edit
  def edit
          @instructor_id = Instructor.find(params[:id]).user_id
  end

  def thank_you
  end

  # POST /instructors
  # POST /instructors.json
  def create
    @instructor = Instructor.new(instructor_params)
    @instructor.user_id = current_user.id unless current_user.nil?
    @instructor.status = "new applicant"
    @instructor.overall_initial_rank = 1
    @instructor.kids_initial_rank = 1
    @instructor.adults_initial_rank = 1

    respond_to do |format|
      if @instructor.save
        # ga_test_cid = params[:ga_client_id]
        # puts "The GA ga_client_id is #{ga_test_cid}."
        session[:instructor_id] = @instructor.id
        GoogleAnalyticsApi.new.event('instructor-recruitment', 'new-application-submitted', params[:ga_client_id])
        format.html { render 'thank_you', notice: 'Your instructor application was successfully submitted, you will be contacted shortly. You may also reach out with questions to info@snowschoolers.com' }
        format.json { render action: 'show', status: :created, location: @instructor }
      else
        format.html { render action: 'new' }
        format.json { render json: @instructor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /instructors/1
  # PATCH/PUT /instructors/1.json
  def update
    respond_to do |format|
      if @instructor.update(instructor_params)
        format.html { redirect_to instructor_path, notice: 'Your instructor application was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @instructor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /instructors/1
  # DELETE /instructors/1.json
  def destroy
    @instructor.destroy
    respond_to do |format|
      format.html { redirect_to instructors_url }
      format.json { head :no_content }
    end
  end

  private
    def confirm_user_permissions
      return if current_user.instructor == @instructor || current_user.email == 'brian@snowschoolers.com'
      redirect_to @instructor, notice: 'You do not have permission to edit this page.'
    end

    def confirm_admin_permissions
      return if current_user.email == 'brian@snowschoolers.com' || current_user.user_type == 'Ski Area Partner' || current_user.user_type == "Partner"
      redirect_to root_path, notice: 'You do not have permission to view that page.'
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_instructor
      @instructor = Instructor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def instructor_params
      params.require(:instructor).permit(:first_name, :last_name, :username, :home_resort_location, :contact_email, :performance_ranking, :certification, :phone_number, :bio, :intro, :status, :city, :user_id, :avatar, :confirmed_certification, :overall_initial_rank, :age, :dob, sport_ids:[], location_ids:[], primary_location_ids:[], ski_level_ids:[], snowboard_level_ids:[])
    end
end
