class Subscription < ApplicationRecord
  validates :publisher_class_name, presence: true
  validates :listener_class_name, presence: true
  validates :listener_class_name, uniqueness: { scope: :publisher_class_name }
  validate :listener_class_must_resolve

  scope :active, -> { where(active: true) }
  scope :for_publisher, ->(klass) { where(publisher_class_name: klass.to_s) }

  def listener_class
    listener_class_name.safe_constantize
  end

  private

  def listener_class_must_resolve
    return if listener_class_name.blank?
    return if listener_class

    errors.add(:listener_class_name, "does not resolve to a loadable class (#{listener_class_name.inspect})")
  end
end
