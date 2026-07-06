# Wisper broadcaster that hands events off to ActiveJob so subscribers
# run out-of-band instead of inline with the publisher.
class ActiveJobBroadcaster
  def broadcast(listener, publisher, event, *args, **kwargs)
    WisperEventJob.perform_later(listener.class.name, event.to_s, *args)
  end
end
