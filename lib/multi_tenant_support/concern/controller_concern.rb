module MultiTenantSupport

  module ControllerConcern
    extend ActiveSupport::Concern

    included do
      include ViewHelper

      before_action :set_current_tenant_account

      private

      define_method(MultiTenantSupport.current_tenant_account_method) do
        instance_variable_get("@#{MultiTenantSupport.current_tenant_account_method}")
      end

      def set_current_tenant_account
        tenant_account = MultiTenantSupport::FindTenantAccount.call(
          subdomains: request.subdomains,
          domain: request.domain
        )
        MultiTenantSupport::Current.tenant_account = tenant_account
        instance_variable_set("@#{MultiTenantSupport.current_tenant_account_method}", tenant_account)
      end
    end
  end

  module ViewHelper
    define_method(MultiTenantSupport.current_tenant_account_method) do
      instance_variable_get("@#{MultiTenantSupport.current_tenant_account_method}")
    end
  end
end

ActiveSupport.on_load(:action_controller) do |base|
  base.include MultiTenantSupport::ControllerConcern
end

ActiveSupport.on_load(:action_view) do |base|
  base.include MultiTenantSupport::ViewHelper
end