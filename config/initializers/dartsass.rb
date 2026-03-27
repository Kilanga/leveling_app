# Suppress third-party Sass deprecation noise (Bootstrap internals) in build output.
Rails.application.config.dartsass.build_options << "--quiet-deps"
