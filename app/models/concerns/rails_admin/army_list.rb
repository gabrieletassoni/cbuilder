module RailsAdmin::ArmyList
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label I18n.t("admin.army_builder.label")
      navigation_icon "fa fa-list-ul"
      parent GameFormat
    end
  end
end
