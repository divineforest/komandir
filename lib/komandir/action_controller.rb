module Komandir
  module ControllerMethods

    module ClassMethods
    end

    module InstanceMethods
      def action_signature_valid?(user)
        raise "Blank komandir_random_text" if params[:komandir_random_text].blank?
        raise "Blank komandir_signature" if params[:komandir_signature].blank?
        raise "Blank certificate for user. Make sure user.certificate.body contains certificate" unless user.certificate.try(:body?)

        verification_set = {
          :message => params[:komandir_random_text],
          :signature => params[:komandir_signature],
          :certificate => user.certificate.body
        }
        Cryptopro::Signature.verify(verification_set)
      end
    end

    def self.included(receiver) # :nodoc:
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end

  end
end
