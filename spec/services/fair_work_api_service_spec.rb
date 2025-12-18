require 'rails_helper'

RSpec.describe FairWorkApiService do
  let(:http_client) { double('Net::HTTP') }
  let(:service) { described_class.new(http_client: http_client) }
  let(:award_code) { 'MA000001' }

  describe '#fetch_award_rate' do
    context 'when API call succeeds' do
      let(:mock_response) do
        response = double('Net::HTTPSuccess')
        allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
        allow(response).to receive(:body).and_return({
          'data' => {
            'award' => {
              'code' => award_code,
              'name' => 'Test Award',
              'rates' => [
                {
                  'classification' => 'Level 1',
                  'rate' => 25.50,
                  'effective_date' => '2024-01-01'
                }
              ]
            }
          }
        }.to_json)
        response
      end

      before do
        allow(http_client).to receive(:new).and_return(http_client)
        allow(http_client).to receive(:use_ssl=)
        allow(http_client).to receive(:read_timeout=)
        allow(http_client).to receive(:request).and_return(mock_response)
      end

      it 'returns the award rate' do
        result = service.fetch_award_rate(award_code)

        expect(result).to be_success
        expect(result.rate).to eq(25.50)
        expect(result.classification).to eq('Level 1')
        expect(result.award_code).to eq(award_code)
      end
    end

    context 'when API call fails' do
      let(:mock_response) do
        response = double('Net::HTTPClientError')
        allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)
        allow(response).to receive(:is_a?).with(Net::HTTPNotFound).and_return(false)
        allow(response).to receive(:is_a?).with(Net::HTTPClientError).and_return(true)
        response
      end

      before do
        allow(http_client).to receive(:new).and_return(http_client)
        allow(http_client).to receive(:use_ssl=)
        allow(http_client).to receive(:read_timeout=)
        allow(http_client).to receive(:request).and_return(mock_response)
      end

      it 'returns a failure result' do
        result = service.fetch_award_rate(award_code)

        expect(result).not_to be_success
        expect(result.error).to include('Invalid request to Fair Work API')
      end
    end

    context 'when award is not found' do
      let(:mock_response) do
        response = double('Net::HTTPNotFound')
        allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)
        allow(response).to receive(:is_a?).with(Net::HTTPNotFound).and_return(true)
        response
      end

      before do
        allow(http_client).to receive(:new).and_return(http_client)
        allow(http_client).to receive(:use_ssl=)
        allow(http_client).to receive(:read_timeout=)
        allow(http_client).to receive(:request).and_return(mock_response)
      end

      it 'returns a failure result with award not found message' do
        result = service.fetch_award_rate(award_code)

        expect(result).not_to be_success
        expect(result.error).to include('Award not found')
      end
    end

    context 'when response format is unexpected' do
      let(:mock_response) do
        response = double('Net::HTTPSuccess')
        allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
        allow(response).to receive(:body).and_return('invalid json')
        response
      end

      before do
        allow(http_client).to receive(:new).and_return(http_client)
        allow(http_client).to receive(:use_ssl=)
        allow(http_client).to receive(:read_timeout=)
        allow(http_client).to receive(:request).and_return(mock_response)
      end

      it 'returns a failure result with parsing error' do
        result = service.fetch_award_rate(award_code)

        expect(result).not_to be_success
        expect(result.error).to include('Failed to parse API response')
      end
    end

    context 'when award code is blank' do
      it 'returns a failure result' do
        result = service.fetch_award_rate('')

        expect(result).not_to be_success
        expect(result.error).to include('Award code cannot be blank')
      end

      it 'returns a failure result for nil' do
        result = service.fetch_award_rate(nil)

        expect(result).not_to be_success
        expect(result.error).to include('Award code cannot be blank')
      end
    end
  end
end
