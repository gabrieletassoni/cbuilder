module RailsAdmin::GrantedDeity
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label I18n.t("admin.registries.label")
      navigation_icon "fa fa-file"

      configure :worshiper do
        visible false
      end
    end
  end
end
