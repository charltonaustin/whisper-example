class Order < ApplicationRecord
  validates :customer_name, presence: true
  validates :total_cents, numericality: { greater_than: 0 }
end
