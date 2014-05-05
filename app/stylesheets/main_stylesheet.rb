class MainStylesheet < ApplicationStylesheet

  def setup
    # Add sytlesheet specific setup stuff here.
    # Add application specific setup stuff in application_stylesheet.rb
  end

  def root_view(st)
    st.background_color = color.black
  end

  def title_label(st)
    st.frame = {t: 20, w: 200, h: 18}
    st.centered = :horizontal
    st.text_alignment = :center
    st.text = 'EvictoMate'
    st.color = color.battleship_gray
    st.font = font.medium
  end
  
  def decibel_meter_node(st)
    st.frame = { t: 100, w: 200, h: 40, l: (app_width / 2) - 100}
    st.background_color = color.black
    st.layer.cornerRadius = 5
    st.layer.masksToBounds = true
  end
end
