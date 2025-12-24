module RailsAdmin::MagicPath
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label I18n.t("admin.equipment_and_mysticism.label")
      navigation_icon "fa fa-hat-wizard"
    end
  end
end
