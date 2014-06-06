require 'ege_parser'

pupil = EgeParser::Pupil.new

pupil.name = 'Никитос'
pupil.surname = 'Преблагин'
pupil.patronymic = 'Олегович'
pupil.passport = '453312'
pupil.region = '45'

ege_parser = EgeParser::Parser.new
p ege_parser.get_subjects pupil