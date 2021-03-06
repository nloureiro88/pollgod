require 'csv'

JOBS = ['Student',
        'Teacher',
        'Actor',
        'Clergy',
        'Musician',
        'Philosopher',
        'Visual Artist',
        'Writer',
        'Audiologist',
        'Chiropractor',
        'Dentist',
        'Dietitian',
        'Doctor',
        'Medical Laboratory Scientist',
        'Midwive',
        'Nurse',
        'Occupational Therapist',
        'Optometrist',
        'Pathologist',
        'Pharmacist',
        'Physical Therapist',
        'Physician',
        'Psychologist',
        'Speech-Language Pathologist',
        'Accountant',
        'Actuary',
        'Agriculturist',
        'Architect',
        'Economist',
        'Consultant',
        'Manager',
        'Engineer',
        'Interpreter',
        'Attorney',
        'Advocate',
        'Solicitor',
        'Librarian',
        'Statistician',
        'Surveyor',
        'Urban Planner',
        'Firefighter',
        'Judge',
        'Military',
        'Police',
        'Air Traffic Controller',
        'Aircraft Pilots',
        'Sea Captain',
        'Scientist',
        'Astronomer',
        'Biologist',
        'Botanist',
        'Ecologist',
        'Geneticist',
        'Immunologist',
        'Pharmacologist',
        'Virologist',
        'Zoologist',
        'Chemist',
        'Geologist',
        'Meteorologist',
        'Oceanographer',
        'Physicist',
        'Programmer',
        'Web Developer',
        'Product Designer',
        'Graphic Designer',
        'Web Designer',
        'Other'].sort

puts "Destroying all previous data..."

Report.destroy_all
Answer.destroy_all
Poll.destroy_all
Filter.destroy_all
Category.destroy_all
Friend.destroy_all
User.destroy_all

puts 'Cleaning up Cloudinary via API...'
Cloudinary::Api.delete_all_resources

filepath_users = './db/files/users.csv'

puts "Creating categories..."

category_array = [['Love & Friends', '#CF93C2', 'love.svg'],
                 ['Lifestyle', '#CE7575', 'lifestyle.svg'],
                 ['Entertainment', '#CEA678', 'entertainment.svg'],
                 ['Sports', '#75CEA3', 'sports.svg'],
                 ['Culture', '#9C95CC', 'culture.svg'],
                 ['News & Society', '#759ECE', 'news.svg'],
                 ['Science & Nature', '#75C9CE', 'science.svg'],
                 ['Professional', '#AAAAAA', 'professional.svg']]

category_array.each do |info|
  new_cat = Category.new(name: info[0],
                         color: info[1],
                         icon: info[2])
  new_cat.save!
end

puts "Creating users..."

HOBBIES = ['cinema', 'music', 'books', 'travel', 'gaming',
           'cooking', 'partying', 'gym', 'golf', 'eating out',
           'fashion', 'football', 'tenis', 'dogs', 'cats']

csv_options = { col_sep: ';' }
CSV.foreach(filepath_users, csv_options) do |row|
  new_user_email = "#{row[0].downcase}.#{row[1].downcase}@lewagon.org"
  new_user_hobbies = rand(0..4)
  new_user = User.new(password: '123456',
                      email: new_user_email,
                      first_name: row[0],
                      last_name: row[1],
                      gender: row[4].capitalize,
                      birthdate: Faker::Date.birthday(21, 50),
                      location: row[2],
                      profession: JOBS.sample,
                      hobbies: HOBBIES.sample(new_user_hobbies).join(", "),
                      subscription: ['free', 'premium', 'pro'].sample)
  new_user.remote_photo_url = row[3]
  new_user.save!
end

puts "Creating filters..."

User.all.each do |user|
  Category.all.each do |cat|
    Filter.create(user: user,
                  category: cat,
                  active: rand(0..1).zero?)
  end
end

puts "Creating polls..."

ANSWERS = [['yes', 'no'],
           ['yes', 'no', 'maybe'],
           ['yesterday', 'tomorrow', 'next week', 'next month'],
           ['very low', 'low', 'moderate', 'high', 'very high']]

User.all.each do |user|
  nr_polls = rand(1..5)

  nr_polls.times do
    new_poll_tags = rand(0..4)
    random_date = user.subscription == 'free' ? 7 : 30
    new_poll = Poll.new(user: user,
                        category: Category.all.sample,
                        points: user.subscription == 'free' ? 1 : rand(5..100),
                        qtype: user.subscription == 'free' ? 'open' : ['closed', 'sponsored'].sample, # To test with private in the future
                        question: Faker::GreekPhilosophers.quote.tr(".", "") + "?",
                        optype: 'SCP', # Add other options in the future
                        options: ANSWERS.sample,
                        tags: HOBBIES.sample(new_poll_tags),
                        image: Faker::Placeholdit.image('280x280', 'jpeg', :random),
                        deadline: Faker::Time.between(Date.today + 1, Date.today + random_date, :all))
  new_poll.created_at = Faker::Time.between(12.months.ago, Date.today - 1, :all)
  new_poll.save!
  end
end

puts "Creating friendships... :)"

200.times do
  friends = User.all.sample(2)
  rs = Friend.new(active_user_id: friends[0].id, follow_user_id: friends[1].id, status: 'active')
  rs.save! if rs.valid?
end

puts "Creating answers..."

Poll.all.each do |poll|
  answer_count = rand(4..12)
  answer_users = []
  counter = 0

  until counter == answer_count
    user = User.all.sample
    unless answer_users.include?(user)
      new_answer = Answer.new(user: user,
                              poll: poll,
                              points: poll.points,
                              answer: rand(0..(poll.options.size - 1)),
                              f_love: rand(0..1).zero?,
                              f_funny: rand(0..1).zero?,
                              f_interest: rand(0..1).zero?)
      new_answer.created_at = Faker::Time.between(poll.created_at, Date.today, :all)
      new_answer.save!
      counter += 1
    end
    answer_users << user
  end
  poll.refresh_likes
end


