class HelloCatsListenerTwo
  def order_created(order, message = nil)
    Rails.logger.info("[HelloCatsListener] New Test! Order ##{order.id} created for #{order.customer_name}.")
  end

  def order_creation_failed(order)
    Rails.logger.info("[HelloCatsListener] Hello cats! Order creation failed — #{order.errors.full_messages.join(', ')}")
  end
end
