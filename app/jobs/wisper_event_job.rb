class WisperEventJob < ApplicationJob
  queue_as :default

  def perform(listener_class_name, event, *args)
    listener_class_name.constantize.new.public_send(event, *args)
  end
end
