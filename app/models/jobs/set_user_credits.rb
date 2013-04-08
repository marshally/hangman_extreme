class Jobs::SetUserCredits < Jobs::Base

  def run
    # perform work here
    user_scope = User.where('credits < 20')
    while(user_scope.count > 0) do
      user_scope.each do |user|
        begin
          user.update_attribute(:credits,20)
        rescue ActiveRecord::StaleObjectError => e
          Rails.logger.error(e.message)
        end
      end
    end
  end

end