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

# puts 'Cleaning up Cloudinary via API...'
# Cloudinary::Api.delete_all_resources

filepath_users = './db/files/users_2.csv'
filepath_polls = './db/files/polls.csv'

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
  new_user_email = "#{row[0].downcase}.#{row[1].downcase}@pollgod.org"
  new_user_hobbies = rand(0..4)
  new_user = User.new(password: 'pg54321',
                      email: new_user_email,
                      first_name: row[0],
                      last_name: row[1],
                      gender: row[2].capitalize,
                      birthdate: Faker::Date.birthday(row[3].to_i, row[3].to_i + 1),
                      location: row[4],
                      profession: JOBS.sample,
                      hobbies: HOBBIES.sample(new_user_hobbies).join(", "),
                      subscription: 'free')
  new_user.remote_photo_url = row[5]
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

csv_options = { col_sep: ';' }
CSV.foreach(filepath_polls, csv_options) do |row|

  new_poll = Poll.new(user: User.all.sample,
                      category: Category.find_by(name: row[0]),
                      points: row[2],
                      qtype: row[1].downcase,
                      question: row[3],
                      optype: 'SCP', # Add other options in the future
                      options: row[4].split(", "),
                      tags: row[5].split(", "),
                      deadline: row[6] == "Random" ? Faker::Time.between(5.months.from_now, 10.months.from_now) : DateTime.strptime(row[6], "%d-%m-%Y"))
  new_poll.created_at = Faker::Time.between(12.months.ago, Date.today - 1, :all)
  p new_poll.question
  new_poll.save!
end

puts "Creating friendships... :)"

(User.count * 5).times do
  friends = User.all.sample(2)
  rs = Friend.new(active_user_id: friends[0].id, follow_user_id: friends[1].id, status: 'active')
  rs.save! if rs.valid?
end

puts "Creating answers..."

Poll.all.each do |poll|
  answer_count = rand(5..15)
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


