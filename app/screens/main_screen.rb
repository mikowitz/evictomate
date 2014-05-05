class MainScreen < PM::Screen 
  title 'EvictoMate'

  def on_load
    # Sets a top of 0 to be below the navigation control
    #self.edgesForExtendedLayout = UIRectEdgeNone

    rmq.stylesheet = MainStylesheet
    rmq(self.view).apply_style :root_view

    @nodes = []
    10.times do
      @nodes << rmq.append(UIView, :decibel_meter_node).get
    end

    @title_label = rmq.append(UILabel, :title_label).get
    @nodes.each_with_index do |node, idx|
      i = @nodes.size - idx
      rmq(node).style do |st|
        st.frame = { t: (45 * i) + 50 }
      end
    end

    # Create your UIViews here

    session = AVAudioSession.sharedInstance
    err_ptr = Pointer.new :object
    session.setCategory AVAudioSessionCategoryPlayAndRecord, error: err_ptr
    session.setActive true, error: err_ptr

    @recorder = AVAudioRecorder.alloc.initWithURL url, settings: settings, error: err_ptr
    @recorder.setMeteringEnabled true

    if @recorder.prepareToRecord
      @recorder.record
      @timer = EM.add_periodic_timer 0.5 do
        @recorder.updateMeters
        if @recorder.respond_to?(:averagePower)
          db = @recorder.averagePower
        else
          db = @recorder.averagePowerForChannel(0)
        end
        db = calc_db(db) * 10.0
        @nodes.each_with_index do |node, i|
          i += 1
          rmq(node).style do |st|
            st.background_color = color_for_node(i, db)
          end
        end
      end
    end
  end

  def color_for_node(i, db)
    if i < db || i == db.ceil
      case i
      when 1,2,3,4
        rmq.color.green
      when 5,6,7
        rmq.color.yellow
      when 8,9
        rmq.color.orange
      else
        rmq.color.red
      end
    else
      rmq.color.black
    end
  end

  def calc_db(db)
    if db < -60
      return 0
    elsif db > 0.0
      return 1.0
    else
      root = 2.0
      minAmp = 10.0 ** (0.05 * -60.0)
      inverseAmpRange = 1.0 / (1.0 - minAmp)
      amp = 10.0 ** (0.05 * db)
      adjAmp = (amp - minAmp) * inverseAmpRange
      return adjAmp ** ( 1.0 / root)
    end
  end

  def settings
    @settings ||= {
      :AVFormatIDKey => KAudioFormatAppleIMA4,
      :AVSampleRateKey => 16000,
      :AVNumberOfChannelsKey => 1,
      :AVLinearPCMBitDepthKey => 16,
      :AVLinearPCMIsBigEndianKey => false,
      :AVLinearPCMIsFloatKey => false
    }
  end

  def url
    return @url if @url
    path = NSTemporaryDirectory().stringByAppendingPathComponent("test.caf")
    @url = NSURL.fileURLWithPath(path)
  end

  def nav_left_button
    puts 'Left button'
  end

  def nav_right_button
    puts 'Right button'
  end
end


__END__

# You don't have to reapply styles to all UIViews, if you want to optimize, 
# another way to do it is tag the views you need to restyle in your stylesheet, 
# then only reapply the tagged views, like so:
def logo(st)
  st.frame = {t: 10, w: 200, h: 96}
  st.centered = :horizontal
  st.image = image.resource('logo')
  st.tag(:reapply_style)
end

# Then in willAnimateRotationToInterfaceOrientation
rmq(:reapply_style).reapply_styles


