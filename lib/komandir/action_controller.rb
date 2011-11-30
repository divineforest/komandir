module Komandir
  module ControllerMethods

    module ClassMethods
    end

    module InstanceMethods

      # TODO Переделать user в параметрах через @current_user
      def action_signature_valid?(user)
        raise "Blank komandir_signature" if params[:komandir_signature].blank?
        raise "Blank certificate for user. Make sure user.certificate.body contains certificate" unless user.certificate.try(:body?)

        protocol = Protocol.new(
          :user => user,
          :action_url => request.path,
          :client_ip => request.remote_ip,
          :client_time_epoch => params[:komandir_time],
          :body => serialized_form,
          :signature => params[:komandir_signature]
        )

        protocol.save
      end

      private

        def serialized_form
          # TODO Сортировать по алфавиту
          pairs = request.raw_post.split("&")
          pairs = remove_odd_params(pairs)
          params_string = pairs.join("&")
        end

        def remove_odd_params(pair_strings)
          odd_param_names = %w[utf8 authenticity_token commit komandir_signature komandir_time]
          filtered_param_names = %w[password]
          pair_strings.reject do |pair_string|
            param_name = pair_string.split("=").first
            odd_param_names.include?(param_name) || filtered_param_names.any? { |filtered_param_name| param_name.include?(filtered_param_name) }
          end
        end
    end

    def self.included(receiver) # :nodoc:
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end

  end
end
