require 'open-uri'
require 'net/http'
require 'nokogiri'
require 'mechanize'

require_relative 'error.rb'
require_relative 'pupil.rb'

module EgeParser

	class Parser

		attr_writer :auth_agent

		def auth_agent
			@auth_agent ||= Mechanize.new
			@auth_agent.open_timeout=180
			@auth_agent.read_timeout=180
			@auth_agent
		end

		def get_subjects pupil
			page = auth_agent.post('http://check.ege.edu.ru/ru/index.php', {
					name:                   pupil.name,
					surname:                pupil.surname,
					patronymic:             pupil.patronymic,
					doc_number:             pupil.passport,
					region:                 pupil.region,
					generate_captcha_val => ''
			})

			generate_subjects page
		end

		private

		def generate_captcha_val
			captcha_key = '-a-UHS2Wj8Cy8W4QB4cpZ8y_6XZNUWU'
			page = auth_agent.post('http://check.ege.edu.ru/common/Qaptcha.jquery.php', {
					action:'qaptcha',
					qaptcha_key:captcha_key
			})
			raise EgeParser::CaptchaError if JSON.parse(page.body)['error']
			captcha_key
		end

		def generate_subjects page
			Hash[find_elements(2, page).zip find_elements(5, page)]
		end

		def find_elements row, page
			result = []
			page.search("//table[contains(@class, 'appil_resultat')]/tbody/tr/td[#{row}]").to_a.map{|el|
				parsed = el_to_s(el)
				result << parsed if parsed != nil|| parsed != ''
			}

			check_for_errors page

			raise EgeParser::BadDataError if result.any?{|k| k.empty?} || result.empty?

			result
		end

		def check_for_errors page
			service_error = el_to_s(page.search('//h2'))
			raise EgeParser::ServiceError.new(service_error) unless service_error.empty?

			auth_error = el_to_s(page.search('//div[@id="show_div2"]/form'))
			raise EgeParser::AuthError.new unless auth_error.empty?
		end

		def el_to_s el
			el.to_s.gsub(/<\/?[^>]+>/, '').gsub(/\n|\t/,'').strip
		end
	end
end