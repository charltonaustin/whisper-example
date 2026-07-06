Rails.application.config.to_prepare do
  Wisper.configure do |config|
    config.broadcaster(:async, ActiveJobBroadcaster.new)
  end
end
