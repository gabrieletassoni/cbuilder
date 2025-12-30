module RailsAdmin::GrantedMagicPath
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label I18n.t("admin.registries.label")
      navigation_icon "fa fa-file"

      configure :mage do
        visible false
      end
    end
  end
end
