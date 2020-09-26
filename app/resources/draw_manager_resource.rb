class DrawManagerResource < ApplicationResource

  self.adapter = Graphiti::Adapters::Null

  @draw_mgr = nil

  attribute :draw_tableau, :array, only: [:readable, :writable] do
    debugger
    @object.draw_tableau
  end

  attribute :draw_structure, :array, only: [:readable] do
    debugger
    @object.draw_structure
  end

  # attribute :draw_seeds :array_of_integers, only: [:readable, :writable] do
  #   draw_mgr.draw_seeds
  # end

  # def assign_attributes(model, attributes)
  #   debugger
  #   #attributes.each_pair do |k, v|
  #     #model.send(:"#{k}=", v)
  #   #end
  # end

  def base_scope
    { db: [draw_mgr] }
  end

  def resolve(scope)
    scope[:db]
  end

  # def build(params)
  #   debugger
  #   @draw_mgr = self.model.new(context.current_contest, params)
  # end

  private

  def draw_mgr
    @draw_mgr ||= context.draw_manager
  end

  # def get_draw_manager(myparams = {})
  #       myparams ||= { contest_id: context.current_contest.id }
  #       dmclass = "DrawManager#{context.current_contest.ctype}"
  #       dmclass.constantize.new(myparams)
  # end
end
