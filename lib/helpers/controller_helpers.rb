module WepayRails
  module Helpers
    module ControllerHelpers
      # Get the auth code for the customer
      # arguments are the redirect_uri and an array of permissions that your application needs
      # ex. ['manage_accounts','collect_payments','view_balance','view_user']
      def auth_code_url(redirect_uri, permissions)
        params = {
            :client_id => @config[:client_id],
            :redirect_uri => redirect_uri,
            :scope => permissions.join(',')
        }

        query = params.map do |k, v|
          "#{k.to_s}=#{v}"
        end.join('&')

        "#{@base_uri}/v2/oauth2/authorize?#{query}"
      end

      def redirect_to_wepay_for_auth(redirect_uri, scope)
        redirect_to gateway.auth_code_url(redirect_uri, scope)
      end

      def gateway
        @gateway ||= WepayRails::Payments::Gateway.new
      end

      def wepay_auth_code=(auth_code)
        gateway.wepay_auth_code = auth_code
      end

      def wepay_auth_code
        gateway.wepay_auth_code
      end

      def wepay_auth_header
        {'Authorization' => "Bearer: #{gateway.wepay_auth_code}"}
      end

      def wepay_user
        response = gateway.get("/v2/user", {:headers => wepay_auth_header})
        puts response.inspect
        JSON.parse(response)
      end
    end
  end
end