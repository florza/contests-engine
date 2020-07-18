class DrawManager
  extend ActiveModel::Naming
  include ActiveRecord::Validations

  # required manual definitions for validations in not ActiveRecord classes
  def persisted?
    false
  end

  def new_record?
    true
  end
end
