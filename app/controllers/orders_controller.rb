class OrdersController < ApplicationController
  def new
    @order = Order.new
  end

  def create
    @order = OrderCreator.new.create(order_params)

    if @order.persisted?
      redirect_to new_order_path, notice: "Order ##{@order.id} created — check the Rails log for subscriber output."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:order).permit(:customer_name, :total_cents)
  end
end
