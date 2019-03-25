require 'csv'

puts "Destroying all previous data..."

Answer.destroy_all
Poll.destroy_all
Filter.destroy_all
Category.destroy_all
User.destroy_all

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
                      photo: row[3],
                      gender: row[4],
                      birthdate: Faker::Date.birthday(21, 50),
                      location: row[2],
                      profession: Faker::Job.title,
                      hobbies: HOBBIES.sample(new_user_hobbies),
                      subscription: ['free', 'premium', 'corporate'].sample)
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
                        qtype: user.subscription == 'free' ? 'open' : 'sponsored',
                        question: Faker::GreekPhilosophers.quote.tr(".", "") + "?",
                        optype: 'single choice', # Add other options in the future
                        options: ANSWERS.sample,
                        tags: HOBBIES.sample(new_poll_tags),
                        image: Faker::Placeholdit.image('280x280', 'jpeg', :random),
                        deadline: Faker::Time.between(Date.today + 1, Date.today + random_date, :all))
  new_poll.created_at = Faker::Time.between(7.days.ago, Date.today - 1, :all)
  new_poll.save!
  end
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
end


