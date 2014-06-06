module EgeParser
	class AuthError < StandardError; end
	class ParserError < StandardError; end
	class BadDataError < StandardError; end
	class ServiceError < StandardError; end
	class CaptchaError < StandardError; end
end