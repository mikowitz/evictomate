class DecibelMeterView < UIView
  HEIGHT = 20
  def initWithYPosition(y_pos)
    frame = SugarCube::CoreGraphics.Rect(y_pos, 50 - (height / 2), width, height)
    initWithFrame(frame) 
  end
end
