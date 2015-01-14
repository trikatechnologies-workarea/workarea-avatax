Weblinc::Admin::UsersController.class_eval do

  private

  def user_params
    params.require(:user).permit(
      :email,
      :first_name,
      :last_name,
      :admin,
      :csr,
      :tag_list,
      :currency,
      :password,
      :exemption_no,
      :customer_usage_type
    )
  end
end
