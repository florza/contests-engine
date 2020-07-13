# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# First seed the defined fixtures into the db:
require 'active_record/fixtures'
ActiveRecord::FixtureSet.create_fixtures(
                        "#{Rails.root}/test/fixtures", "users")
ActiveRecord::FixtureSet.create_fixtures(
                        "#{Rails.root}/test/fixtures", "contests")
ActiveRecord::FixtureSet.create_fixtures(
                        "#{Rails.root}/test/fixtures", "participants")
#ActiveRecord::FixtureSet.create_fixtures(
#                        "#{Rails.root}/test/fixtures", "matches")

f = User.all.first
Contest.create!([
  { user_id: f.id,
    name: 'Meine Meisterschaft',
    shortname: 'Meisterschaft',
    description: 'Mit seed() definiertes Turnier',
    contesttype: 'Groups',
    nbr_sets: 1,
    public: true
  }
])
