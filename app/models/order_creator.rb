class OrderCreator
  include Wisper::Publisher

  # Subscriptions are looked up fresh on every instantiation (no caching or
  # preloading at boot) so toggling a row in the `subscriptions` table takes
  # effect on the very next request without restarting the app.
  def initialize
    Subscription.active.for_publisher(self.class).find_each do |subscription|
      listener_class = subscription.listener_class

      if listener_class.nil?
        Rails.logger.warn("[OrderCreator] Skipping subscription ##{subscription.id}: #{subscription.listener_class_name.inspect} does not resolve")
        next
      end

      subscribe(listener_class.new, async: subscription.async)
    end
  end

  def create(params)
    order = Order.new(params)

    if order.save
      broadcast(:order_created, order, "Thanks for your order!")
    else
      broadcast(:order_creation_failed, order)
    end

    order
  end
end
