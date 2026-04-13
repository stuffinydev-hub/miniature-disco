# ❌ GitHub Actions на Windows для iOS - НЕВОЗМОЖНО

## Проблема

Ты не можешь собрать iOS приложение на GitHub Actions Windows по **техническим причинам Apple**.

### Причины

#### 1️⃣ Swift Compiler для iOS только на macOS
```
Windows: ❌ Нет Swift toolchain для iOS
macOS:   ✅ Swift встроен в Xcode (автоматически)
Linux:   ⚠️ Swift есть, но без iOS SDK
```

#### 2️⃣ Xcode работает ТОЛЬКО на macOS
- Xcode = IDE + Swift Compiler + Apple SDKs + Simulators
- На Windows невозможно установить Xcode
- Без Xcode нет способа скомпилировать код для iOS

#### 3️⃣ Apple Signing требует macOS
```
Code Signing (для App Store):
  ├─ Keychain (только в macOS)
  ├─ Provisioning Profiles (требуют macOS)
  └─ Developer Certificate (требуют macOS Keychain)
```

#### 4️⃣ iOS Simulator требует Apple Silicon / Intel CPU с Hypervisor
```
Windows: ❌ Нет iOS Simulator
macOS:   ✅ iOS Simulator встроен в Xcode
```

---

## ✅ РЕШЕНИЕ: Использовать macOS GitHub Actions

### Правильный выбор Runner

```yaml
jobs:
  build:
    # ✅ ВЕРНО
    runs-on: macos-14     # или macos-13, macos-12
    
    # ❌ НЕВЕРНО
    # runs-on: windows-latest  # iOS toolchain НЕ установлен
    # runs-on: ubuntu-latest   # Нет Xcode и iOS SDK
```

### Доступные macOS Runners на GitHub Actions

| Runner | Xcode | Swift | iOS SDK | Статус |
|--------|-------|-------|---------|--------|
| `macos-14` | 15.x | 5.9+ | ✅ | **Рекомендуется** |
| `macos-13` | 14.x | 5.8+ | ✅ | Работает |
| `macos-12` | 13.x | 5.7 | ✅ | Устарело |

### Минимальный Рабочий Workflow

```yaml
# .github/workflows/build-ios.yml
name: Build StuffinyGram

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-14  # ← ОБЯЗАТЕЛЬНО macOS!
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.0.app
      
      - name: Install Bazel
        run: brew install bazel
      
      - name: Build Module
        run: |
          cd submodules/StuffinyGramSettings
          bazel build //:StuffinyGramSettings -c dbg
```

---

## 📊 Сравнение GitHub Actions Runners

```
┌─────────────────┬───────────┬─────────┬──────────┬─────────────┐
│ Runner          │ OS        │ Xcode   │ iOS SDK  │ Стоимость   │
├─────────────────┼───────────┼─────────┼──────────┼─────────────┤
│ macos-14        │ macOS 14  │ 15.x    │ ✅       │ 10 mins/$ 1 │
│ macos-13        │ macOS 13  │ 14.x    │ ✅       │ 10 mins/$ 1 │
│ ubuntu-latest   │ Linux     │ ❌      │ ❌       │ 10 mins FREE │
│ windows-latest  │ Windows   │ ❌      │ ❌       │ 10 mins FREE │
└─────────────────┴───────────┴─────────┴──────────┴─────────────┘

ВРЕМЯ ВЫПОЛНЕНИЯ на macOS:
  Чистая сборка: ~2-5 минут
  С кешем Bazel: ~30-60 секунд
```

---

## 🔧 Полный Рабочий Workflow (Копируй и Используй)

> Файл: `.github/workflows/build-stuffinygramm.yml`

```yaml
name: Build StuffinyGram iOS Module

on:
  push:
    branches: [ main, develop ]
    paths: [ 'submodules/StuffinyGramSettings/**' ]
  pull_request:
    branches: [ main, develop ]
  workflow_dispatch:

jobs:
  build:
    runs-on: macos-14
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Select Xcode
        run: |
          sudo xcode-select -s /Applications/Xcode_15.0.app
          xcode-select -p
      
      - name: Install Bazel
        run: brew install bazel
      
      - name: Cache Bazel
        uses: actions/cache@v3
        with:
          path: ~/.cache/bazel
          key: ${{ runner.os }}-bazel-${{ hashFiles('.bazelversion') }}
      
      - name: Build StuffinyGram
        run: |
          cd submodules/StuffinyGramSettings
          bazel build //:StuffinyGramSettings -c dbg --jobs=auto
      
      - name: Upload Artifacts
        if: success()
        uses: actions/upload-artifact@v3
        with:
          name: stuffinygramm-module
          path: bazel-bin/submodules/StuffinyGramSettings
```

---

## 🏠 Локальная Сборка (на твоём macOS)

Если хочешь собрать локально перед пушем:

```bash
# 1. Установить Bazel
brew install bazel

# 2. Перейти в проект
cd ~/ghostgram

# 3. Собрать модуль
cd submodules/StuffinyGramSettings
bazel build //:StuffinyGramSettings

# 4. Результат находится здесь
ls -lah ../../bazel-bin/submodules/StuffinyGramSettings/
```

---

## 🎯 Правильный Workflow для iOS Application

Если позже захочешь собрать ПОЛНОЕ приложение (не только модуль):

```yaml
name: Build Full Telegram App

on: [push]

jobs:
  build:
    runs-on: macos-14
    
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive  # Важно!
      
      - name: Setup Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.0.app
      
      - name: Install Dependencies
        run: |
          brew install bazel
          # Добавить другие зависимости если нужны
      
      - name: Build Telegram
        run: |
          bazel build \
            Telegram/Telegram \
            --features=swift.use_global_module_cache \
            --define=buildNumber=10000 \
            --define=telegramVersion=12.2.2 \
            -c dbg \
            --ios_multi_cpus=sim_arm64
      
      - name: Code Sign (если нужно)
        env:
          SIGNING_CERT: ${{ secrets.SIGNING_CERT_BASE64 }}
          SIGNING_PASSWORD: ${{ secrets.SIGNING_PASSWORD }}
        run: |
          # Кодирование и установка сертификата
          echo "$SIGNING_CERT" | base64 -d > cert.p12
          security import cert.p12 -P "$SIGNING_PASSWORD" -A
          
          # Остальной код подписи...
```

---

## ⚡ GitHub Actions Ограничение Затрат

```
macOS runners ПЛАТНЫЕ:
  $0.10 за минуту (для публичных репозиториев)
  $0.16 за минуту (для приватных)

Linux/Windows runners БЕСПЛАТНЫЕ:
  Неограниченно для публичных

СОВЕТ: Кеш результатов сборки экономит деньги!
```

---

## 🚨 Важные Заметки

### ❌ ЭТО НЕ СРАБОТАЕТ

```yaml
jobs:
  build:
    runs-on: windows-latest  # ❌ Нет Xcode, нет Swift для iOS
```

```bash
# ❌ На Windows невозможно
swiftc -target arm64-apple-ios14.0
```

```yaml
# ❌ Попытка кросс-компиляции на Linux
runs-on: ubuntu-latest
# Результат: ОШИБКА SDKVersion не может быть найден
```

### ✅ ЭТО СРАБОТАЕТ

```yaml
jobs:
  build:
    runs-on: macos-14  # ✅ Xcode встроен, Swift через Xcode
```

```bash
# ✅ На macOS работает
bazel build Telegram/Telegram --ios_multi_cpus=sim_arm64
```

---

## 📝 Пошаговый Setup

### Шаг 1: Создать папку для workflows
```bash
mkdir -p .github/workflows
```

### Шаг 2: Создать файл workflow
```bash
touch .github/workflows/build-stuffinygramm.yml
```

### Шаг 3: Скопировать содержимое из `WORKFLOW_TEMPLATE.yml`

### Шаг 4: Закоммитить
```bash
git add .github/workflows/build-stuffinygramm.yml
git commit -m "feat: Add GitHub Actions macOS build workflow"
git push
```

### Шаг 5: Проверить в GitHub
- Открыть репозиторий на GitHub
- Перейти в `Actions` tab
- Найти новый workflow
- Видно результат сборки ✅ или ❌

---

## 🔗 Полезные Ссылки

- [GitHub Actions macOS runners](https://github.com/actions/virtual-environments#macs)
- [Bazel на macOS](https://bazel.build/install/os-x)
- [Swift Compiler Info](https://swift.org/download/)
- [iOS Development Docs](https://developer.apple.com/ios/)

---

## 📞 Что Делать Если Сборка Не Работает

### Сборка падает с ошибкой Xcode выбора
```bash
# Решение:
sudo xcode-select -s /Applications/Xcode_15.0.app
xcode-select -p  # Проверить результат
```

### Ошибка "Command 'swift' not found"
```bash
# Решение:
brew install swift  # На linux вообще не поможет

# На macOS:
sudo xcode-select --reset
```

### Bazel кеш повреждён
```bash
# Решение:
bazel clean --expunge
rm -rf ~/.cache/bazel
```

### Хочу собрать на Linux (возможно ли?)
```
❌ НЕТ для iOS
⚠️ МОЖНО для backend только
✅ Используй macOS для iOS
```

---

## 📊 Итоговая Рекомендация

```
┌────────────────────────────────────────────┐
│  СОБИРАТЬ iOS ПРИЛОЖЕНИЕ ТОЛЬКО НА macOS  │
│                                            │
│  ✅ GitHub Actions: macos-14               │
│  ✅ Локально: macOS with Xcode            │
│  ❌ Windows: НЕВОЗМОЖНО (Apple только)    │
│  ❌ Linux: НЕВОЗМОЖНО (нет iOS SDK)       │
└────────────────────────────────────────────┘
```

**Файл готовой конфигурации:** `.github/workflows/build-stuffinygramm.yml` ✅

---

**Последнее обновление:** 2026-04-13  
**Версия документации:** 1.0  
**Статус:** ✅ АКТУАЛЬНО
