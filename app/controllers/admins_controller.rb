class AdminsController < ApplicationController
  skip_before_action :ensure_admin_role
  skip_before_action :ensure_clerk_role, except: [:menu, :menu_item, :show_all_users]

  def menu
  end

  def menu_item
    @category = MenuCategory.find(params[:category_id])
    @items = MenuItem.getall_items(@category.id)
  end

  def index
    @orders = Order.order("delivered_at DESC NULLS FIRST, id DESC")
  end

  def show_all_users
    @role = params[:role]
    users=User.getUsersByRole(@role)
    if(!users.empty?)
      @users=users
    else
      @users=nil
    end
  end

  def date_search
    customer_id = params[:customer_id]
    from = params[:from_date]
    to = params[:to_date]
    unless(customer_id.empty?)
      unless(from.empty? && to.empty?)
        @orders = User.find(customer_id).orders.where("created_at >= ? AND created_at <= ?", from, to.to_datetime.end_of_day).order("delivered_at DESC NULLS FIRST", id: :desc)
        flash[:error]=nil
      else
        @orders = User.find(customer_id).orders.order("delivered_at DESC NULLS FIRST, id DESC")
        flash[:error] = nil
      end
    else
      unless(from.empty? && to.empty?)
        @orders = Order.where("created_at >= ? AND created_at <= ?", from, to.to_datetime.end_of_day).order("delivered_at DESC NULLS FIRST", id: :desc)
        flash[:error]=nil
      else
        flash[:error] = "Enter valid detial"
        @orders = Order.order("delivered_at DESC NULLS FIRST, id DESC")
      end
    end
      render "index"
  end

  def order_search
    id = params[:search]
    if(Order.exists?(id))
      @orders = Order.where("id=?",id)
      flash[:error]=nil
    else
      @orders = Order.order("delivered_at DESC NULLS FIRST, id DESC")
      flash[:error] = "Invalid Order_id"
    end
    render "index"
  end

  def list_search
    case params[:list]
      when "allorders"
        @orders = Order.order("delivered_at DESC NULLS FIRST, id DESC")
      when "pending"
        @orders = Order.where("delivered_at is NULL and cancel_reason is NULL").order(id: :desc)
      when "delivered"
        @orders = Order.where("delivered_at is not NULL and address_id is not NULL").order(id: :desc)
      when "cancel"
        @orders = Order.where("cancel_reason is not NULL").order(id: :desc)
      when "walkin"
        @orders = Order.where("address_id is NULL").order(id: :desc)
    end
    flash[:error]=nil
    @status_order = params[:list]
    render "index"
  end
end
