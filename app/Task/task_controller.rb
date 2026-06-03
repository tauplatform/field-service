require 'rho/rhocontroller'
require 'helpers/browser_helper'

class TaskController < Rho::RhoController
  include BrowserHelper

  # GET /Task
  def index
    @tasks = Task.find(:all, :order => 'created_at', :orderdir => 'DESC')
    render :back => '/app'
  end

  # GET /Task/{1}
  def show
    @task = Task.find(@params['id'])
    if @task
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Task/new
  def new
    @task = Task.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Task/{1}/edit
  def edit
    @task = Task.find(@params['id'])
    if @task
      render :action => :edit, :back => url_for(:action => :show, :id => @task.object)
    else
      redirect :action => :index
    end
  end

  # POST /Task/create
  def create
    attrs = @params['task'] || {}
    attrs['status']     ||= 'pending'
    attrs['created_at'] = Time.now.strftime('%Y-%m-%dT%H:%M:%S')
    @task = Task.create(attrs)
    redirect :action => :index
  end

  # POST /Task/{1}/update
  def update
    @task = Task.find(@params['id'])
    if @task
      @task.update_attributes(@params['task'])
    end
    redirect :action => :index
  end

  # POST /Task/{1}/delete
  def delete
    @task = Task.find(@params['id'])
    @task.destroy if @task
    redirect :action => :index 
  end

  # ------------------------------------------------------------------
  # POST /app/Task/{id}/update_status   (AJAX-friendly status transition)
  # ------------------------------------------------------------------
  def update_status
    @task = Task.find(@params['id'])
    if @task
      new_status = @params['status']
      @task.update_attributes('status' => new_status)
    end
    redirect :action => :index
  end

  # ------------------------------------------------------------------
  # POST /app/Task/{id}/capture_photo
  # Launches the device camera; result delivered asynchronously to
  # photo_callback action.
  # ------------------------------------------------------------------
  def capture_photo
    @task = Task.find(@params['id'])
    unless @task
      redirect :action => :index
      return
    end

    # Store task id in a callback URL parameter so we know which task
    # to update when the photo comes back.
    # callback_url = url_for(
    #   :action => :photo_callback,
    #   :query  => { 'task_id' => @task.object }
    # )
    Rho::Camera.takePicture({}, url_for(:action => :photo_callback))
    # Camera UI launches — execution does NOT continue here synchronously.
    # The app suspends waiting for the callback.
  end

  # ------------------------------------------------------------------
  # POST /app/Task/photo_callback
  # Called asynchronously by the Camera native module after the user
  # takes or cancels a photo.
  # ------------------------------------------------------------------
  def photo_callback
    status    = @params['status']
    task_id   = @params['task_id']
    image_uri = @params['imageUri'] || @params['image_uri']

    if status == 'ok' && task_id && image_uri
      task = Task.find(task_id)
      task.update_attributes('photo_path' => image_uri) if task
    end

    # Redirect back to the task detail view
    redirect :action => :show, :id => task_id
  end
end
