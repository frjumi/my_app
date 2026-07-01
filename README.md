# my_app — Winx transformations rating

Учебное Rails-приложение для оценивания изображений превращений Winx Club.

- **Стек:** Ruby 3.3.6, Rails 7.1, PostgreSQL, Haml, Bootstrap 3, jQuery, Turbolinks
- **Деплой:** Render

## Быстрый старт

```bash
bundle install
bin/rails db:create db:migrate db:seed
cp .env.example .env   # задать OPENAI_API_KEY для функции «Интересные факты»
bin/rails server
```

Откройте `http://localhost:3000/ru/work` (нужен вход).

## Документация

| Файл | Описание |
|------|----------|
| [docs/IMPLEMENTATION.md](docs/IMPLEMENTATION.md) | Техническая реализация всего проекта |
| [docs/OMNIAI.md](docs/OMNIAI.md) | **Внедрение OmniAI:** интересные факты, API, сервис, UI, настройка |

## OmniAI (кратко)

Генерация текста «Интересные факты» на `/work` через **omniai** + **OpenAI**. Текст сохраняется в `images.ai_fact` и повторно не запрашивается у API.

Подробности, примеры кода и troubleshooting — в **[docs/OMNIAI.md](docs/OMNIAI.md)**.
