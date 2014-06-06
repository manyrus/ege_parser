require 'ege_parser'

pupil = EgeParser::Pupil.new

pupil.name = 'Никитос'
pupil.surname = 'Преблагин'
pupil.patronymic = 'Олегович'
pupil.passport = '453312'
pupil.region = '45'

ege_parser = EgeParser::Parser.new
begin
	p ege_parser.get_subjects pupil #output as {'subject'=>'status', 'subject#2'=>'status2'}
rescue EgeParser::AuthError #see all errors in error.rb
	p 'Auth error('
end
