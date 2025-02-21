class PasswordRecordsController < ApplicationController
  before_action :set_password_record, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  before_action :require_verification, only: [:show]

  # GET /password_records or /password_records.json
  def index
    @password_records = PasswordRecord.accessible_by(current_user).order(created_at: :desc)
    @password_records_made_by_current_user = current_user.password_records
    @password_records_shared_with_current_user = PasswordRecord.accessible_by(current_user).order(updated_at: :desc)
  end

  # GET /password_records/1 or /password_records/1.json
  def show
    @password_record = PasswordRecord.friendly.find(params[:id])
  end

  # GET /password_records/new
  def new
    @password_record = current_user.password_records.new
  end

  # GET /password_records/1/edit
  def edit
  end

  # POST /password_records or /password_records.json
  def create
    @password_record = current_user.password_records.new(password_record_params)

    respond_to do |format|
      if @password_record.save
        format.html { redirect_to password_records_path, notice: "Password record was successfully created." }
        format.json { render :show, status: :created, location: @password_record }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @password_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /password_records/1 or /password_records/1.json
  def update
    respond_to do |format|
      if @password_record.update(password_record_params)
        format.html { redirect_to @password_record, notice: "Password record was successfully updated." }
        format.json { render :show, status: :ok, location: @password_record }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @password_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /password_records/1 or /password_records/1.json
  def destroy
    @password_record.destroy!

    respond_to do |format|
      format.html { redirect_to password_records_path, status: :see_other, notice: "Password record was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_password_record
      @password_record = PasswordRecord.friendly.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def password_record_params
      params.require(:password_record).permit(:username, :password, :url, :title)
    end

    def require_verification
      unless session[:verified]
        redirect_to verify_security_path, alert: "Please verify your identity first."
      end
    end
end
