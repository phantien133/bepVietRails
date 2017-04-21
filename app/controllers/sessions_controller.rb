class SessionsController < Devise::SessionsController
  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => '#{controller_path}#failure')
    sign_in_and_redirect(resource_name, resource)
  end

  def sign_in_and_redirect(resource_or_scope, resource)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    return render :json => {:success => true}
    redirect_to root_path
  end

  def failure
    return render :json => {:success => false, :errors => ["Login failed."]}
  end
end
