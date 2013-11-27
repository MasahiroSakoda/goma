module Goma
  class Mailer
    class << self
      def send_email(mailer, mailing_method, record)
        mail = mailer.send(mailing_method, record)
        mail.deliver
      end
    end
  end
end
