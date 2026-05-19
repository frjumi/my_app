# frozen_string_literal: true

# Загрузка: bin/rails db:seed

Theme.destroy_all
Image.destroy_all
User.destroy_all
Value.destroy_all

ActiveRecord::Base.connection.tables.each do |table|
  ActiveRecord::Base.connection.reset_pk_sequence!(table)
rescue StandardError
  nil
end

# Темы (id 1 — заглушка для выпадающего списка)
Theme.create!([
                  { name: '---' },
                  { name: 'Какое из превращений Блум Вам нравится больше?' },
                  { name: 'Какое из превращений Стеллы Вам нравится больше?' },
                  { name: 'Какое из превращений Музы Вам нравится больше?' }
                ])

# Изображения из app/assets/images/pictures/
# Блум_* → theme_id: 2, Стелла_* → theme_id: 3, Муза_* / Музой_* → theme_id: 4
Image.create!([
                # --- Блум (theme_id: 2) ---
                { name: 'Блум. Базовое превращение', file: 'Блум_База.jpeg', theme_id: 2, ave_value: 0.0 },
                { name: 'Блум. Чармикс', file: 'Блум_Чармикс.jpeg', theme_id: 2, ave_value: 0.0 },
                { name: 'Блум. Энчантикс', file: 'Блум_Энчантикс.jpeg', theme_id: 2, ave_value: 0.0 },
                { name: 'Блум. Беливикс', file: 'Блум_Беливикс.jpeg', theme_id: 2, ave_value: 0.0 },
                { name: 'Блум Блумикс', file: 'Блум_Блумикс.jpeg', theme_id: 2, ave_value: 0.0 },
                { name: 'Блум Гармоникс', file: 'Блум_Гармоникс.jpeg', theme_id: 2, ave_value: 0.0 },
                { name: 'Блум Лавикс', file: 'Блум_Лавикс.jpeg', theme_id: 2, ave_value: 0.0 },
                { name: 'Блум Мермедикс', file: 'Блум_Мермедикс.jpeg', theme_id: 2, ave_value: 0.0 },
                { name: 'Блум Мификс', file: 'Блум_Мификс.jpeg', theme_id: 2, ave_value: 0.0 },
                { name: 'Блум Сиреникс', file: 'Блум_Сиреникс.jpeg', theme_id: 2, ave_value: 0.0 },
                { name: 'Блум Софикс', file: 'Блум_Софикс.jpeg', theme_id: 2, ave_value: 0.0 },
                # --- Стелла (theme_id: 3) ---
                { name: 'Стелла Беливикс', file: 'Стелла_Беливикс.jpeg', theme_id: 3, ave_value: 0.0 },
                { name: 'Стелла Чармикс', file: 'Стелла_Чармикс.jpeg', theme_id: 3, ave_value: 0.0 },
                { name: 'Стелла Энчантикс', file: 'Стелла_Энчантикс.jpeg', theme_id: 3, ave_value: 0.0 },
                # --- Муза (theme_id: 4) ---
                { name: 'Муза Беливикс', file: 'Муза_Беливикс.jpeg', theme_id: 4, ave_value: 0.0 },
                { name: 'Муза Сиреникс', file: 'Муза_Сиреникс.jpeg', theme_id: 4, ave_value: 0.0 },
                { name: 'Муза Энчантикс', file: 'Муза_Энчантикс.jpeg', theme_id: 4, ave_value: 0.0 }
              ])

puts "Seeded: #{Theme.count} themes, #{Image.count} images"
