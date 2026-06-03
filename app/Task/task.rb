# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Task
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with Task.
  # enable :sync

  #add model specific code here
  property :photo_path, :blob

  def status_label
    case status
    when 'pending' then 'Pending'
    when 'in_progress' then 'In Progress'
    when 'done' then 'Done'
    else status.to_s.capitalize
    end
  end

  def status_badge_class
    case status
    when 'pending'     then 'label-default'
    when 'in_progress' then 'label-warning'
    when 'done'        then 'label-success'
    else 'label-default'
    end
  end

end
