module Komandir
  class Railtie < Rails::Railtie
    initializer "komandir.action_controller" do |app|
      require 'komandir/action_controller'
      ActionController::Base.send :include, Komandir::ControllerMethods
    end
  end
end
