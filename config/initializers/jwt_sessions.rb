JWTSessions.token_store = :memory
JWTSessions.encryption_key = Rails.application.credentials.jwt[:encryption_key]

# Short timeout of access token (in seconds) to debug the refresh cycle
# JWTSessions.access_exp_time = 30
