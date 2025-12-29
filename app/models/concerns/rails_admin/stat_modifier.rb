module RailsAdmin::StatModifier
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label I18n.t("admin.modification_engine.label")
      navigation_icon "fa fa-pen-to-square"

      configure :source do
        visible false
      end
    end
  end
end
