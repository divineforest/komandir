module Komandir
  module ControllerMethods

    module ClassMethods
    end

    module InstanceMethods
      # TODO Переделать user в параметрах через @current_user
      def action_signature_valid?(user)
        raise "Blank komandir_signature" if params[:komandir_signature].blank?
        raise "Blank certificate for user. Make sure user.certificate.body contains certificate" unless user.certificate.try(:body?)

        verification_set = {
          :message => digest,
          :signature => params[:komandir_signature],
          :certificate => user.certificate.body
        }
        Cryptopro::Signature.verify(verification_set)
      end

      private

        def digest
          "#{system_params}:#{serialized_form}"
        end

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

        def system_params
          check_client_time!
          "#{request.path}:#{request.remote_ip}:#{params[:komandir_time]}"
        end

        def check_client_time!
          if params[:komandir_time].present?
            server_time_epoch = Time.now.to_i
            client_time_epoch = params[:komandir_time].to_i
            raise "Время в подписи неверное" if (client_time_epoch - server_time_epoch).abs > 60
          end
        end
    end

    def self.included(receiver) # :nodoc:
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end

  end
end
