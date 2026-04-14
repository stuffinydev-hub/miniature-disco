# Деплой Telegram iOS через GitHub Actions

## Что настроено

GitHub Actions автоматически соберет iOS приложение на macOS runner'е при каждом push в main.

## Необходимые секреты

Перейдите в настройки репозитория: `Settings` → `Secrets and variables` → `Actions` → `New repository secret`

Добавьте следующие секреты:

### 1. TELEGRAM_API_ID
Получите на https://my.telegram.org/apps
- Войдите с вашим номером телефона
- Создайте новое приложение
- Скопируйте `api_id`

### 2. TELEGRAM_API_HASH
Там же на https://my.telegram.org/apps
- Скопируйте `api_hash`

### 3. APPLE_TEAM_ID (опционально для полной сборки)
Если у вас есть Apple Developer аккаунт:
- Откройте Keychain Access на Mac
- Найдите сертификат `Apple Development`
- В деталях найдите `Organizational Unit` - это Team ID

## Как запустить сборку

### Автоматически
Просто сделайте push в main:
```bash
git add .
git commit -m "Update code"
git push origin main
```

### Вручную
1. Перейдите на GitHub в ваш репозиторий
2. Откройте вкладку `Actions`
3. Выберите `Build Telegram iOS`
4. Нажмите `Run workflow`

## Результат

После успешной сборки:
- Артефакты будут доступны во вкладке `Actions` → выберите запуск → `Artifacts`
- Файлы хранятся 7 дней

## Ограничения

- Сборка работает только для симулятора (без подписи кода)
- Для сборки на реальное устройство нужен Apple Developer аккаунт ($99/год)
- GitHub Actions дает 2000 минут/месяц бесплатно для macOS

## Troubleshooting

Если сборка падает:
1. Проверьте что все секреты добавлены
2. Посмотрите логи в Actions
3. Убедитесь что submodules загружены (`git submodule update --init --recursive`)
