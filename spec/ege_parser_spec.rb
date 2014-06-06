require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe EgeParser::Parser, :fast do
  let(:pupil){
    pupil = EgeParser::Pupil.new
    pupil.name  = 'Сер'
    pupil.surname = 'ПоЛяков'
    pupil.patronymic = 'Сергеевич'
    pupil.passport = '342412'
    pupil.region = '30'

    pupil
  }

  def stub_captcha(is_error = false)
    stub_request(:post, 'http://check.ege.edu.ru/common/Qaptcha.jquery.php').to_return(body:{error:is_error}.to_json)
  end

  def stub_result file_name
    stub_request(:post, "http://check.ege.edu.ru/ru/index.php")
                .to_return(
                    :status => 200,
                    :body => File.read(File.dirname(__FILE__) + "/templates/#{file_name}.html"),
                    :headers => {'Content-Type'=>'text/html'}
                )
  end

  describe '#get_subjects' do
    context 'when bad captcha' do
      it 'throw EgeParser::CaptchaError' do
        stub_captcha(true)

        expect{subject.get_subjects pupil}.to raise_error(EgeParser::CaptchaError)
      end
    end

    context 'when not authed' do
      it 'throw EgeParser::AuthError' do
        stub_captcha
        stub_result 'authed_error'

        expect{subject.get_subjects pupil}.to raise_error(EgeParser::AuthError)
      end
    end

    context 'when some subject is empty' do
      it 'throw EgeParser::ParserError' do
        stub_captcha
        stub_result 'bad_data'

        expect{p subject.get_subjects pupil}.to raise_error(EgeParser::BadDataError)
      end
    end

    context 'all ok' do
      it 'parse all data and get result' do
        stub_captcha
        stub_result 'success'

        subject.get_subjects(pupil).should ==
            {'Русский язык' => 'Нет результата (обработка)',
             'Математика' => 'Экзамен не проходил',
             'Физика' => 'Экзамен не проходил',
             'Информатика и ИКТ' => 'Экзамен не проходил'}
      end
    end
  end
end


