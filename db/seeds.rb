puts "Destroying all previous data..."

Answer.destroy_all
Poll.destroy_all
Filter.destroy_all
Category.destroy_all
User.destroy_all

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

