FactoryBot::SyntaxRunner.include(ActionDispatch::TestProcess)

FactoryBot.define do
  factory :document do
    svg_content { "asdf" }

    trait :with_pdf do
      pdf_file { fixture_file_upload("empty.pdf") }
    end
  end
end
