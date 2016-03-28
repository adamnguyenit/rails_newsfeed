FactoryGirl.define do
  factory :activity, class: RailsNewsfeed::Activity do
    content { Faker::Lorem.sentence }
    object { Faker::Lorem.word }
  end

  factory :activity_empty, class: RailsNewsfeed::Activity do
    content nil
    object nil
  end

  factory :activity_empty_content, class: RailsNewsfeed::Activity do
    content nil
    object { Faker::Lorem.word }
  end

  factory :activity_empty_object, class: RailsNewsfeed::Activity do
    content { Faker::Lorem.sentence }
    object nil
  end

  factory :activity_with_object_test, class: RailsNewsfeed::Activity do
    content { Faker::Lorem.sentence }
    object 'test'
  end
end
