class SessionsController < Devise::SessionsController
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in_and_redirect(resource_name, resource)
  end

  def sign_in_and_redirect(resource_or_scope, resource)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    render :json => {:success => true}
    add_message_flash :notice, t(:welcome, name: current_user.name)
  end

  def failure
    warden.custom_failure!
    render json: { success: false, errors: [ t(:user_invalid)] }
  end

  def after_sign_in_path_for(resource_or_scope)
    session[:forwarding_url] || root_path
  end

  def after_sign_up_path_for(resource)
    session[:forwarding_url] || root_path
  end

  protected
  def auth_options
    {:scope => resource_name, :recall => "#{controller_path}#failure"}
  end
end

