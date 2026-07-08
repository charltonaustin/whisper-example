class HelloCatsListenerBadSignature
  # order_created is always broadcast with 2 positional args (order, message)
  # this method only accepts 1, so ListenerUpload should reject it.
  def order_created(order)
    Rails.logger.info("[HelloCatsListenerBadSignature] Hello cats! Order ##{order.id} created.")
  end
end
