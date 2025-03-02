class PasswordRecordsController < ApplicationController
  before_action :set_password_record, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  before_action :require_verification, only: %i[ show ]

  # GET /password_records or /password_records.json
  def index
    search_title = params[:search_by_title]&.strip&.downcase
    search_username = params[:search_by_username]&.strip&.downcase
    search_url = params[:search_by_url]&.strip&.downcase

    base_query = PasswordRecord.for_user(current_user)
    @password_records_made_by_current_user = current_user.password_records.order(created_at: :desc)
    @password_records_shared_with_current_user = base_query.where.not(user_id: current_user.id).order(updated_at: :desc)

    if search_title.present? || search_username.present?
      conditions = []
      conditions << PasswordRecord.arel_table[:title].matches("%#{search_title}%") if search_title.present?
      conditions << PasswordRecord.arel_table[:username].matches("%#{search_username}%") if search_username.present?
      conditions << PasswordRecord.arel_table[:url].matches("%#{search_url}%") if search_url.present?

      search_condition = conditions.inject(&:and)

      @password_records_made_by_current_user = @password_records_made_by_current_user.where(search_condition)
      @password_records_shared_with_current_user = @password_records_shared_with_current_user.where(search_condition)
    end

    @password_records = base_query.order(created_at: :desc)
    @password_records = @password_records.where(search_condition) if search_title.present? || search_username.present? || search_url.present?
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
    if @password_record.user_id == current_user.id
      @password_record.destroy!
      respond_to do |format|
        format.html { redirect_to password_records_path, status: :see_other, notice: "Password record was successfully destroyed." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to password_records_url, alert: "You are not allowed to perform this action" }
        format.json { head :no_content }
      end
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
      Rails.logger.info "Session after opening the tab: #{session.to_hash}"
      if session[:verified].blank? || session[:verified_at].blank? || session[:verified_at] < 3.minutes.ago || session[:verified] == nil
        session[:verified] = nil
        redirect_to verify_security_path, alert: "Session expired. Please verify your identity again."
      else
        session[:verified_at] = Time.current
      end
    end
end
