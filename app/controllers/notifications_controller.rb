class NotificationsController < ApplicationController
  load_and_authorize_resource :notification

  def index
    respond_to do |format|
      format.html { render :index }
      format.js {}
      format.json { render json: @notifications }
    end
  end

  def show
  end

  def new
    respond_to do |format|
      format.html {}
      format.js   {}
    end
  end

  def edit
    respond_to do |format|
      format.html {}
      format.js {}
    end
  end

  def create
    current_or_guest_user

    respond_to do |format|
      if @notification.save
        #format.html { redirect_to @notification, notice: 'Notifikační oblast byla úspěšně přidána.' }
        format.html { redirect_to notifications_path, notice: 'Notifikační oblast byla úspěšně přidána.' }
        format.js {
          @notifications = current_or_guest_user.notifications
          render :create
        }
        format.json { render :show, status: :created, location: @notification }
      else
        format.js   { render :new }
        format.html { render :new }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @notification.update(notification_params)
        format.html { redirect_to @notification, notice: 'Notifikační oblast byla úspěšně upravena.' }
        format.json { render :show, status: :ok, location: @notification }
        format.js {
          @notifications = current_or_guest_user.notifications
          render :create
        }
      else
        format.js   { render :edit }
        format.html { render :edit }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @notification.destroy
    respond_to do |format|
      format.html { redirect_to notifications_url, notice: 'Notifikační oblast byla smazána' }
      format.json { head :no_content }
    end
  end

  private

  def notification_params
    params.require(:notification).permit(:message, :gps_location, :lat, :lng, :distance)
  end


end
