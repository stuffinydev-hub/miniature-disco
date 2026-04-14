# GitHub Actions Optimization для Telegram iOS

## Проблема

При сборке Telegram iOS на GitHub Actions процесс падал с ошибкой "The operation was canceled" на этапе анализа 35,284 целей Bazel.

## Причины

1. **Таймаут шага** - По умолчанию GitHub Actions имеет таймаут 60 минут для шага
2. **Нехватка памяти** - rules_xcodeproj требует много RAM для анализа больших проектов
3. **Отсутствие кэширования** - Каждый раз анализируются все цели заново

## Решения

### 1. Увеличение таймаутов ✅

```yaml
jobs:
  build:
    timeout-minutes: 360  # 6 часов для job
    
    steps:
    - name: Generate Xcode project
      timeout-minutes: 150  # 2.5 часа для генерации
```

**Почему это помогает:**
- Job timeout: 360 минут (6 часов) вместо дефолтных 360
- Step timeout: 150 минут для генерации проекта
- Telegram iOS - огромный проект, первая генерация может занять 60-120 минут

### 2. Кэширование Bazel ✅

```yaml
- name: Cache Bazel
  uses: actions/cache@v4
  with:
    path: |
      ~/telegram-bazel-cache
      ~/.cache/bazel
    key: bazel-${{ runner.os }}-${{ hashFiles('**/*.bzl', '**/*.bazel') }}
    restore-keys: |
      bazel-${{ runner.os }}-
```

**Почему это помогает:**
- Сохраняет результаты анализа между запусками
- Вторая сборка будет в 5-10 раз быстрее
- Экономит время и деньги на GitHub Actions

### 3. Оптимизация памяти Bazel ✅

Добавлены флаги в `.bazelrc`:

```bash
# Ограничение параллелизма
build:ci --jobs=4
build:ci --local_ram_resources=12288  # 12 GB
build:ci --local_cpu_resources=4

# Уменьшение использования памяти
build:ci --discard_analysis_cache
build:ci --notrack_incremental_state
build:ci --nokeep_state_after_build

# Worker optimization
build:ci --experimental_worker_max_multiplex_instances=4
build:ci --experimental_worker_memory_limit_mb=2048
```

**Почему это помогает:**
- `--jobs=4` - ограничивает параллельные задачи (вместо дефолтных 8)
- `--local_ram_resources=12288` - резервирует 12 GB RAM (из 14 GB доступных)
- `--discard_analysis_cache` - освобождает память после анализа
- `--experimental_worker_memory_limit_mb=2048` - ограничивает память для worker'ов

### 4. Мониторинг памяти ✅

```bash
(while true; do
  echo "[$TIMESTAMP] Memory status:"
  vm_stat | perl -ne '...'
  sleep 300
done) &
```

**Почему это помогает:**
- Показывает использование памяти каждые 5 минут
- Помогает диагностировать OOM (Out of Memory) проблемы
- Логи доступны в GitHub Actions output

### 5. Диагностика ошибок ✅

```yaml
- name: Upload Bazel logs on failure
  if: failure()
  with:
    path: |
      ~/.cache/bazel/_bazel_runner/*/command.log
      ~/.cache/bazel/_bazel_runner/*/java.log*
```

**Почему это помогает:**
- Автоматически загружает логи при ошибке
- Можно скачать и проанализировать локально
- Помогает понять причину падения

## Ожидаемые результаты

### Первый запуск (без кэша)
- ⏱️ Время: 60-120 минут
- 💾 Память: пик ~10-12 GB
- 📦 Кэш: ~2-5 GB

### Последующие запуски (с кэшем)
- ⏱️ Время: 10-30 минут
- 💾 Память: пик ~6-8 GB
- 📦 Кэш: используется существующий

## Альтернативные решения

### Вариант A: Self-hosted runner (если проблемы продолжаются)

Если GitHub Actions runner'ы недостаточно мощные:

1. Настроить self-hosted macOS runner с 32+ GB RAM
2. Использовать более мощный Mac (M2 Max/Ultra)
3. Настроить локальный Bazel remote cache

### Вариант B: Коммит сгенерированного проекта

Если генерация слишком долгая:

1. Сгенерировать `Telegram.xcodeproj` локально
2. Закоммитить в репозиторий
3. В CI только собирать, без генерации

**Плюсы:**
- Быстрая сборка в CI (5-15 минут)
- Не нужна генерация каждый раз

**Минусы:**
- Большой размер репозитория (+100-500 MB)
- Нужно регенерировать при изменении BUILD файлов
- Merge conflicts в .xcodeproj

### Вариант C: Использование Bazel Remote Cache

Настроить удаленный кэш для Bazel:

```bash
build --remote_cache=https://your-cache-server.com
build --remote_upload_local_results=true
```

**Плюсы:**
- Кэш доступен всем разработчикам
- Еще быстрее чем GitHub Actions cache

**Минусы:**
- Требует настройки сервера
- Дополнительные расходы

## Диагностика проблем

### Если сборка все еще падает с "canceled"

1. **Проверьте логи памяти:**
   ```
   Скачайте артефакт с логами
   Найдите строки "Memory status"
   Если "Pages free" < 500 MB - проблема в памяти
   ```

2. **Проверьте время выполнения:**
   ```
   Если упало ровно через 60/90/120 минут - проблема в таймауте
   Увеличьте timeout-minutes
   ```

3. **Проверьте Bazel логи:**
   ```
   Скачайте артефакт "bazel-logs"
   Откройте command.log
   Ищите "OutOfMemoryError" или "killed"
   ```

### Если сборка падает с OOM (Out of Memory)

1. **Уменьшите параллелизм:**
   ```bash
   build:ci --jobs=2  # вместо 4
   build:ci --local_ram_resources=10240  # вместо 12288
   ```

2. **Отключите extensions:**
   ```bash
   --disableExtensions  # уже добавлено
   ```

3. **Используйте incremental build:**
   ```bash
   # Не используйте --discard_analysis_cache
   # Bazel будет использовать больше памяти, но быстрее
   ```

## Мониторинг

### Проверка успешности

После успешной сборки проверьте:

```bash
✓ Telegram.xcodeproj exists
✓ Bazel cache size: ~2-5 GB
✓ Total time: < 150 minutes
✓ Peak memory: < 12 GB
```

### Метрики для отслеживания

- **Build time**: должно уменьшаться с каждым запуском
- **Cache hit rate**: должен расти до 80-90%
- **Memory usage**: не должен превышать 13 GB
- **Disk usage**: кэш не должен превышать 10 GB

## Дополнительные оптимизации

### 1. Использование macos-14 (ARM64)

```yaml
runs-on: macos-14  # ARM64, быстрее чем Intel
```

### 2. Shallow clone

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 1  # только последний коммит
```

### 3. Параллельная загрузка submodules

```yaml
- uses: actions/checkout@v4
  with:
    submodules: recursive
```

## Заключение

Основные изменения для исправления проблемы:

1. ✅ Увеличен timeout до 150 минут для генерации
2. ✅ Добавлено кэширование Bazel
3. ✅ Оптимизированы флаги Bazel для CI
4. ✅ Добавлен мониторинг памяти
5. ✅ Улучшена диагностика ошибок

Эти изменения должны решить проблему "The operation was canceled" и обеспечить стабильную сборку.
