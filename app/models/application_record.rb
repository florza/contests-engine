class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # create a new token
  def get_token
    SecureRandom.urlsafe_base64
  end

end
