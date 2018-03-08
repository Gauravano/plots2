task send: :environment do
  SubscriptionMailer.sending_digest()
end