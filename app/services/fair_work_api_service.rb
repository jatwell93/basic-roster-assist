# frozen_string_literal: true

# Service for integrating with the Fair Work API to retrieve award rates
# Used when configuring awards for staff members to fetch current base rates
class FairWorkApiService
  BASE_URL = "https://api.fairwork.gov.au"
  API_VERSION = "v1"

  # Result object for API responses
  class Result
    attr_reader :rate, :classification, :award_code, :error

    def initialize(success:, rate: nil, classification: nil, award_code: nil, error: nil)
      @success = success
      @rate = rate
      @classification = classification
      @award_code = award_code
      @error = error
    end

    def success?
      @success
    end
  end

  def initialize(http_client: Net::HTTP)
    @http_client = http_client
  end

  def fetch_award_rate(award_code)
    return Result.new(success: false, error: "Award code cannot be blank") if award_code.blank?

    response = make_api_request(award_code)

    if response.is_a?(Net::HTTPSuccess)
      parse_successful_response(response, award_code)
    else
      return handle_api_error(response)
    end
  rescue JSON::ParserError => e
    Rails.logger.error("Fair Work API JSON parsing error for award #{award_code}: #{e.message}")
    Result.new(success: false, error: "Failed to parse API response")
  rescue StandardError => e
    Rails.logger.error("Fair Work API error for award #{award_code}: #{e.message}")
    Result.new(success: false, error: "API request failed")
  end

  private

  def make_api_request(award_code)
    uri = URI("#{BASE_URL}/#{API_VERSION}/awards/#{award_code}")
    http = @http_client.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 30

    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/json"
    request["User-Agent"] = "Basic-Roster-Assist/1.0"

    http.request(request)
  rescue StandardError => e
    # Re-raise to be caught by the main rescue block
    raise e
  end

  def parse_successful_response(response, award_code)
    data = JSON.parse(response.body)

    # Extract the most recent rate from the award data
    award_data = data.dig("data", "award")
    return Result.new(success: false, error: "Invalid API response format") unless award_data

    rates = award_data["rates"]
    return Result.new(success: false, error: "No rates found for this award") if rates.blank?

    # Get the most recent rate (assuming rates are ordered by effective_date desc)
    latest_rate = rates.first
    rate = latest_rate["rate"]
    classification = latest_rate["classification"]

    Result.new(
      success: true,
      rate: rate,
      classification: classification,
      award_code: award_code
    )
  rescue JSON::ParserError
    Result.new(success: false, error: "Failed to parse API response")
  end

  def handle_api_error(response)
    error_message = if response.is_a?(Net::HTTPNotFound)
                      "Award not found"
                    elsif response.is_a?(Net::HTTPClientError)
                      "Invalid request to Fair Work API"
                    elsif response.is_a?(Net::HTTPServerError)
                      "Fair Work API is currently unavailable"
                    else
                      "API request failed"
                    end

    Rails.logger.error("Fair Work API error: #{response.class} - #{error_message}")
    Result.new(success: false, error: error_message)
  end
end
