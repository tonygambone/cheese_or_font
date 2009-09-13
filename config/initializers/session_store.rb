# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_cheeseorfont_session',
  :secret      => '0d3e6221849a22a1b78e9cc7536a6df3ad4327d1bd721279335386742b706efe5597bd3f00ace681ceb7e8a82e227883c7392ddd6a6721e0200434e725ee67eb'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
