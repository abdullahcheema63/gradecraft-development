class ChangeAllowsCanvasDefaultToFalse < ActiveRecord::Migration[5.2]
  def change
    change_column_default :courses, :allows_canvas, from: true, to: false
  end
end
