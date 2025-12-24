module RailsAdmin::ListNexus
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label I18n.t("admin.army_builder.label")
      navigation_icon "fa fa-file"
      parent ArmyList
      visible false
    end
  end
end
