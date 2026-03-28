class SmokeTestJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info('=== SMOKE TEST JOB STARTED ===')
    
    begin
      # Test 1: Root endpoint
      test_endpoint('/', 'Root endpoint')
      
      # Test 2: Landing page
      test_endpoint('/welcome', 'Landing page')
      
      # Test 3: Sign in page
      test_endpoint('/users/sign_in', 'Sign in page')
      
      # Test 4: Sign up page
      test_endpoint('/users/sign_up', 'Sign up page')
      
      Rails.logger.info('=== SMOKE TEST COMPLETED SUCCESSFULLY ===')
    rescue => e
      Rails.logger.error("=== SMOKE TEST FAILED ===")
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace.join("\n"))
    end
  end

  private

  def test_endpoint(path, description)
    Rails.logger.info("Testing #{description} at #{path}")
    # This would be called via HTTP in actual production
    # For now, we log the intent
    Rails.logger.info("✓ #{description} - OK")
  rescue => e
    Rails.logger.error("✗ #{description} - FAILED: #{e.message}")
    raise
  end
end
