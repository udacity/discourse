#
# A helper class to send an email. It will also handle a nil message, which it considers
# to be "do nothing". This is because some Mailers will decide not to do work for some
# reason. For example, emailing a user too frequently. A nil to address is also considered
# "do nothing"
#
# It also adds an HTML part for the plain text body
#
require_dependency 'email/renderer'
require 'uri'
require 'openssl'

module Email
  class Sender

    def initialize(message, email_type, user=nil)
      @message =  message
      @email_type = email_type
      @user = user
    end

    def send
      return if @message.blank?
      return if @message.to.blank?
      return if @message.body.blank?

      @message.charset = 'UTF-8'

      opts = {}

      # Only use the html template on digest emails
      opts[:html_template] = true if (@email_type == 'digest')

      renderer = Email::Renderer.new(@message, opts)

      unless @message.html_part
        @message.html_part = Mail::Part.new do
          content_type 'text/html; charset=UTF-8'
          body renderer.html
        end
      end

      @message.parts[0].body = @message.parts[0].body.to_s.gsub(/\[\/?email-indent\]/, '')

      @message.text_part.content_type = 'text/plain; charset=UTF-8'

      # Set up the email log
      to_address = @message.to
      to_address = to_address.first if to_address.is_a?(Array)
      email_log = EmailLog.new(email_type: @email_type,
                               to_address: to_address,
                               user_id: @user.try(:id))


      host = Email::Sender.host_for(Discourse.base_url)

      @message.header['List-Id'] = Email::Sender.list_id_for(SiteSetting.title, host)

      topic_id = header_value('X-Discourse-Topic-Id')
      post_id = header_value('X-Discourse-Post-Id')
      reply_key = header_value('X-Discourse-Reply-Key')

      if topic_id.present?
        email_log.topic_id = topic_id

        topic_identitfier = "<topic/#{topic_id}@#{host}>"
        @message.header['In-Reply-To'] = topic_identitfier
        @message.header['References'] = topic_identitfier
      end

      email_log.post_id = post_id if post_id.present?
      email_log.reply_key = reply_key if reply_key.present?

      # Remove headers we don't need anymore
      @message.header['X-Discourse-Topic-Id'] = nil
      @message.header['X-Discourse-Post-Id'] = nil
      @message.header['X-Discourse-Reply-Key'] = nil

      add_udacity_hmac!

      @message.deliver

      # Save and return the email log
      email_log.save!
      email_log

    end

    def self.host_for(base_url)
      host = "localhost"
      if base_url.present?
        begin
          uri = URI.parse(base_url)
          host = uri.host.downcase if uri.host.present?
        rescue URI::InvalidURIError
        end
      end
      host
    end

    def self.list_id_for(site_name, host)
      "\"#{site_name.gsub(/\"/, "'")}\" <discourse.forum.#{Slug.for(site_name)}.#{host}>"
    end

    private

    HMAC_HEADERS = ['from', 'to', 'subject', 'message-id', 'date', 'x-udacity-target-accounts',
      'x-udacity-category', 'x-udacity-ga-campaign', 'x-udacity-email-template']

    def header_value(name)
      header = @message.header[name]
      return nil unless header
      header.value
    end

    def update_hmac(hm, *args)
      args.each { |v|
        v = v.gsub /\s+/, ' '
        v = v.encode('utf-8')
        hm.update(v)
      }
    end

    def add_udacity_hmac!
      hmac_key = SiteSetting.udacity_email_hmac_key
      return if hmac_key.nil? || hmac_key.empty?

      # these headers are needed to calculate the HMAC
      @message.add_message_id unless @message.has_message_id?
      @message.add_date unless @message.has_date?

      hmac = OpenSSL::HMAC.new(hmac_key, 'sha256')
      HMAC_HEADERS.each { |h|
        next unless @message.header[h]
        update_hmac(hmac, h.downcase, ': ', @message.header[h].value)
      }
      @message.parts.each { |p|
        update_hmac(hmac, p.body.raw_source.rstrip)
      }
      @message.header['X-Udacity-HMAC'] = hmac.hexdigest
    end
  end
end
