class PrimaryLocationsController < ApplicationController
  before_action :set_primary_location, only: [:show, :edit, :update, :destroy]

  # GET /primary_locations
  # GET /primary_locations.json
  def index
    @primary_locations = PrimaryLocation.all.sort_by { |location| location.name.downcase}
    @locations_to_csv = PrimaryLocation.all
    respond_to do |format|
          format.html
          format.csv { send_data @locations_to_csv.to_csv, filename: "primary_locations-#{Date.today}.csv" }
          format.xls
    end
  end

  def import
   PrimaryLocation.import(params[:file])
   redirect_to primary_locations_path, notice: "New locations data successfully imported."
  end

  def delete_all
    PrimaryLocation.delete_all
    redirect_to primary_locations_path, notice: "All primary locations have been deleted."
  end

  # GET /primary_locations/1
  # GET /primary_locations/1.json
  def show
  end

  # GET /primary_locations/new
  def new
    @primary_location = PrimaryLocation.new
  end

  # GET /primary_locations/1/edit
  def edit
  end

  # POST /primary_locations
  # POST /primary_locations.json
  def create
    @primary_location = PrimaryLocation.new(primary_location_params)

    respond_to do |format|
      if @primary_location.save
        format.html { redirect_to @primary_location, notice: 'Primary location was successfully created.' }
        format.json { render :show, status: :created, location: @primary_location }
      else
        format.html { render :new }
        format.json { render json: @primary_location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /primary_locations/1
  # PATCH/PUT /primary_locations/1.json
  def update
    respond_to do |format|
      if @primary_location.update(primary_location_params)
        format.html { redirect_to @primary_location, notice: 'Primary location was successfully updated.' }
        format.json { render :show, status: :ok, location: @primary_location }
      else
        format.html { render :edit }
        format.json { render json: @primary_location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /primary_locations/1
  # DELETE /primary_locations/1.json
  def destroy
    @primary_location.destroy
    respond_to do |format|
      format.html { redirect_to primary_locations_url, notice: 'Primary location was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_primary_location
      @primary_location = PrimaryLocation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def primary_location_params
      params.require(:location).permit(:name, :calendar_status, :partner_status, :region, :state, :logo, :vertical_feet, :base_elevation, :peak_elevation, :skiable_acres, :average_snowfall, :lift_count, :address, :night_skiing, :city, :state_abbreviation, :closing_date)
    end
end
