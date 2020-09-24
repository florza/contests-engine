class DrawManagerResource < ApplicationResource

  # attribute :input, :hash
  attribute :draw_tableau,   :array,             only: [:writable]
  # attribute :draw_seeds,     :array_of_integers, only: [:readable, :writable]
  attribute :draw_structure, :array,             only: [:readable]

  # attribute :draw_tableau do
  #   @object.draw_tableau
  # end

  # attribute :draw_seeds do
  #   @draw_mgr.draw_seeds
  # end

  attribute :draw_structure do
    debugger
    @object.draw_structure
  end

  # def build(params)
  #   debugger
  #   @draw_mgr = self.model.new(context.current_contest, params)
  # end

end
