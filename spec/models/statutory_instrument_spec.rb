require "spec_helper"
require "models/valid_against_schema"

RSpec.describe StatutoryInstrument do
  let(:payload) { FactoryBot.create(:statutory_instrument) }
  include_examples "it saves payloads that are valid against the 'specialist_document' schema"

  it "is not exportable" do
    expect(described_class).not_to be_exportable
  end
end