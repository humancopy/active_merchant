module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Paypal
        class EncryptedHelper < Helper
          def form_fields
            #Encrypt the transaction information
            paypal_params = super.form_fields.inject({:cert_id => PAYPAL_CERT_ID}) do |mem, (field, value)|
              mem[field] = value
              mem
            end
            # logger.info("\n\npaypal_params = #{paypal_params.inspect}\n\n")

            {
              :cmd => '_s-xclick',
              :encrypted => encrypt_for_paypal(paypal_params)
            }
          end
          protected
          def encrypt_for_paypal(values)  
            signed = OpenSSL::PKCS7::sign(OpenSSL::X509::Certificate.new(APP_CERT_PEM), OpenSSL::PKey::RSA.new(APP_KEY_PEM, ''), values.map { |k, v| "#{k}=#{v}" }.join("\n"), [], OpenSSL::PKCS7::BINARY)  
            OpenSSL::PKCS7::encrypt([OpenSSL::X509::Certificate.new(PAYPAL_CERT_PEM)], signed.to_der, OpenSSL::Cipher::Cipher::new("DES3"), OpenSSL::PKCS7::BINARY).to_s.gsub("\n", "")  
          end
          
        end
      end
    end
  end
end


