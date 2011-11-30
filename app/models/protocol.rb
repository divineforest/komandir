class Protocol < ActiveRecord::Base

  belongs_to :user

  before_validation :set_client_time, :on => :create
  before_validation :set_account_name, :on => :create
  before_validation :set_certificate, :on => :create

  validates :action_url, :presence => true
  validates :client_time_epoch, :presence => true
  validates :client_time, :presence => true
  validates :client_ip, :presence => true
  validates :body, :presence => true
  validates :signature, :presence => true
  validates :account_name, :presence => true
  validate :validate_signature

  attr_accessor :client_time_epoch

    private

      def set_client_time
        self.client_time = Time.at(client_time_epoch.to_i)
      end

      def set_account_name
        if user.respond_to?(:email)
          self.account_name = user.email
        end
      end

      def set_certificate
        self.certificate_id = user.certificate.id
      end

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
