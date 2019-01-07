module Google
  module UrlShortener
    class Url < Base
      include Request
      attr_reader :long_url, :short_url, :status, :created_at, :analytics

      def initialize(opts={})
        opts.each_pair do |k, v|
          self.instance_variable_set(:"@#{k}", v)
        end
      end

      def decode!
        if @projection
          params   = validate_and_prepare_params(:shortUrl => self.short_url, :projection => Analytics::PROJECTION_LEVEL)
        else
          params = validate_and_prepare_params(shortUrl: self.short_url)
        end

        response = get(params)

        @created_at = Date.parse(response["created"]) if response["created"]
        @analytics  = Analytics.from_hash(response["analytics"]) if response["analytics"]
        @long_url   = response["longUrl"]
      end
      alias_method :expand!, :decode!

      def encode!
        params   = validate_and_prepare_params(:longUrl => self.long_url)
        response = post(params)

        @short_url = response["id"]
      end
      alias_method :shorten!, :encode!

    private

      def validate_and_prepare_params(params={})
        params.each_pair do |k, v|
          validate(k, params)
        end

        params
      end

      def validate(key, hash={})
        if hash[key].nil? || hash[key].empty?
          raise "Key :#{key} missing from request parameters!"
        end
      end
    end
  end
end
