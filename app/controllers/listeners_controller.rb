class ListenersController < ApplicationController
  def create
    file = params[:listener_file]

    if file.blank?
      return redirect_to subscriptions_path, alert: "Choose a .rb file to upload."
    end

    result = ListenerUpload.call(file.read)

    if result.valid?
      filename = "#{result.class_name.underscore}.rb"
      File.write(Rails.root.join("app", "listeners", filename), result.source)

      redirect_to subscriptions_path,
        notice: "Listener #{result.class_name} uploaded to app/listeners/#{filename} — ready to use in a subscription right away."
    else
      redirect_to subscriptions_path, alert: result.errors.join(" ")
    end
  end
end
