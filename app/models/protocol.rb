class Protocol < ActiveRecord::Base

  belongs_to :user

  validate :validate_signature

  attr_accessor :client_time_epoch

  # TODO: Validate:
  #   user_id
  #   action_url
  #   client_ip
  #   client_time
  #   body
  #   signature

    private

      def validate_signature
        verification_set = {
          :message => digest,
          :signature => signature,
          :certificate => user.certificate.body
        }
        unless Cryptopro::Signature.verify(verification_set)
          errors.add(:signature, "Signature not valid")
        end
      end

      def digest
        "#{system_params}:#{body}"
      end

      def system_params
        check_client_time!
        "#{action_url}:#{client_ip}:#{client_time_epoch}"
      end

      def check_client_time!
        if client_time_epoch.present?
          server_time_epoch = Time.now.to_i
          self.client_time_epoch = client_time_epoch.to_i
          raise Komandir::WrongTime if (client_time_epoch - server_time_epoch).abs > 60
        end
      end

end


# == Schema Information
#
# Table name: protocols
#
#  id             :integer         not null, primary key
#  user_id        :integer
#  certificate_id :integer
#  action_url     :string(255)
#  account_name   :string(255)
#  client_ip      :string(255)
#  client_time    :datetime
#  body           :text
#  signature      :text
#  created_at     :datetime
#  updated_at     :datetime
#
