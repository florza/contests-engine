class DrawManager

  attr_reader :errors

  def errors?
    !@errors.empty?
  end
end
