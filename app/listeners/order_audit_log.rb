class OrderAuditLog
  def order_created(order, _message = nil)
    Rails.logger.info("[OrderAuditLog] AUDIT: order ##{order.id} created for #{order.customer_name} (#{order.total_cents} cents)")
  end

  def order_creation_failed(order)
    Rails.logger.info("[OrderAuditLog] AUDIT: order creation failed — #{order.errors.full_messages.join(', ')}")
  end
end
