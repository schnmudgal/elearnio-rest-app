shared_examples_for 'resource_not_foundable' do |model, error_message|

  context "when #{model} is not present" do
    it "does NOT delete any #{model}" do
      expect{ request }.not_to change{ model.count }
    end

    it 'returns NOT FOUND error' do
      request

      expect(response.code).to eq('404')
      expect(response.parsed_body['errors']).to match_array([error_message])
    end
  end
end
