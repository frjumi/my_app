# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Theme.destroy_all
Image.destroy_all
User.destroy_all
Value.destroy_all

# Сброс счётчиков primary key
ActiveRecord::Base.connection.tables.each do |table|
  ActiveRecord::Base.connection.reset_pk_sequence!(table)
rescue
  nil # Некоторые таблицы могут не иметь последовательности
end

# Создаём темы (первая – заглушка, как в методичке)
themes = Theme.create([
                        { name: "---" },  # id:1
                        { name: "Какое из превращений Блум Вам нравится больше?" },
                        { name: "Какое из произведений художника П.Пикассо наилучшим образом характеризует его творчество?" },
                        { name: "Какое из произведений художника А.Матисса наилучшим образом характеризует его творчество?" }
                      ])

images = Image.create([
                        { name: "Блум. Базовое превращение", file: "Блум_База.jpeg", theme_id: 2, ave_value: 0 },
                        { name: "Блум. Чармикс", file: "Блум_Чармикс.jpeg", theme_id: 2, ave_value: 0 },
                        { name: "Блум. Энчантикс", file: "Блум_Энчантикс.jpeg", theme_id: 2, ave_value: 0 },
                        { name: "Блум. Беливикс", file: "Блум_Беливикс.jpeg", theme_id: 4, ave_value: 0 }
                      # Добавьте ещё 6-11 изображений по аналогии
                      ])

# Создаём пользователя (пароль захешируется благодаря has_secure_password, если вы его добавили в User)
# Если в модели User нет password_digest, пока создаём без пароля или добавьте поле.
# Для лабораторной мы можем оставить без пароля, но методичка показывает password.
# Если нужно с паролем – добавьте в Gemfile bcrypt и миграцию add_password_digest_to_users, но это позже.

# Создание пользователя (если ещё нет)
user = User.find_or_create_by(email: "expert@example.com") do |u|
  u.name = "Эксперт Фролова"
end

puts "Seeded #{Theme.count} themes, #{Image.count} images, #{User.count} users, #{Value.count} values"