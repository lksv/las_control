class NotificationsController < ApplicationController
  before_filter  :current_or_guest_user
  load_and_authorize_resource :notification
  skip_load_resource only: [:index, :create]

  def index
    @notifications = current_or_guest_user.notifications.accessible_by(current_ability)
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
    @tags_filter = @notification.tags.join(',')

    @tags_filter_values = @notification.tags.reduce({}) do |memo, tag|
      name = Category.new(tag).name
      memo[tag] = name if name
      memo
    end

    respond_to do |format|
      format.html {}
      format.js {}
    end
  end

  def create
    @notification = current_or_guest_user.notifications.build(notification_params)

    respond_to do |format|
      if @notification.save
        #format.html { redirect_to @notification, notice: 'Notifikační oblast byla úspěšně přidána.' }
        format.html { redirect_to notifications_path, notice: 'Notifikační oblast byla úspěšně přidána.' }
        format.js {
          @notifications = current_or_guest_user.notifications
          render :index
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
          render :index
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
      format.js {
          @notifications = current_or_guest_user.notifications
          render :index
      }
    end
  end

  private

  def notification_params
    params.require(:notification).permit(:message, :gps_location, :lat, :lng, :distance, :tags)
  end


end
