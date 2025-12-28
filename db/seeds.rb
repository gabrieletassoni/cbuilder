puts "Seeding Data into DB from cbuilder"

# App Name
Settings.app_name = "S-ciànter Confrontation Builder"

# Run all the seeds from ./seeds/base_data.rb
require_relative "seeds/initial_catalog_seeds"
