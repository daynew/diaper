RSpec.describe NotifyPartnerJob, job: true do
  describe "#perform" do
    let(:request) { create(:request) }
    let(:mailer) { double(:mailer) }

    before do
      allow(RequestsConfirmationMailer).to receive(:confirmation_email).and_return(mailer)
      allow(mailer).to receive(:deliver_later)
    end

    it "is expected to call RequestsConfirmationMailer" do
      NotifyPartnerJob.perform_now(request.id)
      expect(RequestsConfirmationMailer).to have_received(:confirmation_email).with(request)
      expect(mailer).to have_received(:deliver_later)
    end
  end
end
