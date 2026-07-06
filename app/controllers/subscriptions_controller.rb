class SubscriptionsController < ApplicationController
  def index
    @subscriptions = Subscription.order(:publisher_class_name, :listener_class_name)
    @subscription = Subscription.new(publisher_class_name: "OrderCreator")
  end

  def create
    @subscriptions = Subscription.order(:publisher_class_name, :listener_class_name)
    @subscription = Subscription.new(subscription_params)

    if @subscription.save
      redirect_to subscriptions_path, notice: "Subscription added."
    else
      render :index, status: :unprocessable_entity
    end
  end

  def update
    subscription = Subscription.find(params[:id])
    subscription.update!(active: params[:subscription][:active])
    redirect_to subscriptions_path, notice: "Subscription updated."
  end

  private

  def subscription_params
    params.require(:subscription).permit(:publisher_class_name, :listener_class_name, :async, :active)
  end
end
