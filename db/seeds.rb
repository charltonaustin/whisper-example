# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

[
  { publisher_class_name: "OrderCreator", listener_class_name: "OrderNotifier", async: true,  active: true },
  { publisher_class_name: "OrderCreator", listener_class_name: "OrderBilling",  async: false, active: true }
  # OrderAuditLog is intentionally not seeded here — it ships in the codebase
  # but stays dormant until a Subscription row is added via /subscriptions,
  # demonstrating that a new listener can be enabled without restarting the app.
].each do |attrs|
  Subscription.find_or_create_by!(
    publisher_class_name: attrs[:publisher_class_name],
    listener_class_name: attrs[:listener_class_name]
  ) do |s|
    s.async  = attrs[:async]
    s.active = attrs[:active]
  end
end
