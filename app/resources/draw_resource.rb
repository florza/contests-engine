class DrawResource < ApplicationResource

  self.adapter = Graphiti::Adapters::Null
  self.model = DrawManager

  @draw_mgr = nil

  attribute :draw_tableau, :array, only: [:readable, :writable] do
    @object.draw_tableau
  end

  attribute :draw_structure, :array, only: [:readable] do
    @object.draw_structure
  end

  attribute :draw_seeds, :array_of_integer_ids, only: [:readable, :writable] do
    @object.draw_seeds
  end

  def base_scope
    { db: [context.draw_manager] }
  end

  def resolve(scope)
    scope[:db]
  end

  # def build(params)
  #   debugger
  #   @draw_mgr = self.model.new(context.current_contest, params)
  # end

end
