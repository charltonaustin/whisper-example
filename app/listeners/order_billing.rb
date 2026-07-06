class OrderBilling
  def order_created(order, _message = nil)
    Rails.logger.info("[OrderBilling] Charging #{order.customer_name} #{order.total_cents} cents for order ##{order.id}")
  end

  def order_creation_failed(order)
    Rails.logger.info("[OrderBilling] Skipping billing, order failed validation: #{order.errors.full_messages.join(', ')}")
  end
end
