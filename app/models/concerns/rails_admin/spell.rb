module RailsAdmin::Spell
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label I18n.t("admin.equipment_and_mysticism.label")
      navigation_icon "fa fa-scroll"
      parent MagicPath
    end
  end
end
