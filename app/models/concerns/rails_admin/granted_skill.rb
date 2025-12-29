module RailsAdmin::GrantedSkill
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label I18n.t("admin.registries.label")
      navigation_icon "fa fa-file"

      configure :target do
        visible false
      end
    end
  end
end
