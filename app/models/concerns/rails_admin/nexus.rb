module RailsAdmin::Nexus
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label I18n.t("admin.equipment_and_mysticism.label")
      navigation_icon "fa fa-wand-magic-sparkles"
    end
  end
end
