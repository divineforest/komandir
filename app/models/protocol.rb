class Protocol < ActiveRecord::Base

  class WrongTime < Exception; end

  belongs_to :user

  before_create :validate_signature

  # Options:
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
        errors[:base] << "Signature not valid" unless Cryptopro::Signature.verify(verification_set)
      end

      def digest
        "#{system_params}:#{body}"
      end

      def system_params
        check_client_time!
        "#{action_url}:#{client_ip}:#{client_time}"
      end

      def check_client_time!
        if client_time?
          server_time_epoch = Time.now.to_i
          client_time_epoch = client_time.to_i
          raise WrongTime if (client_time_epoch - server_time_epoch).abs > 60
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
