class OrderNotifier
  def order_created(order, str)
    Rails.logger.info("[OrderNotifier] Order ##{order.id} placed by #{order.customer_name} for #{order.total_cents} cents")
    Rails.logger.info("[OrderNotifier] #{str}")
  end
end
