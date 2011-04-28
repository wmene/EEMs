# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_eems_session',
  :secret      => '51utj3pgrl24lawzhgzspd6301ndf47qvnqcvafksqnsrykmensbdt3pb3lqsjln0n8ubgtnt81aqkut15m30w650d3ig3xfzyxf'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
