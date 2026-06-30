# GitScripts

A set of scripts for Git workflow automation and integration with IDEs such as WebStorm, PhpStorm, and IntelliJ IDEA.

*Read this in other languages: [Русский](#gitscripts-ru)*

## Project Structure

1. **`git-flow.sh`** — an interactive Bash script that automates the release process:
   - Updates the `dev` branch.
   - Interactively increments the project version in `pom.xml` (options include patch, minor, major, or manual input) and commits the change.
   - Updates the local `master` branch from `origin/master`.
   - Merges `master` into `dev`.
   - Pushes `dev` to `origin`.
   - Switches to `master` and merges `dev` into it.
   - Pushes `master` to `origin`.
   
2. **`setup-run-config.sh`** — a helper script to quickly set up a Run Configuration in your IDE:
   - Creates a run configuration named **"Assembly on preprod"** in the specified target project.
   - Allows running `git-flow.sh` directly from the IDE interface (e.g., WebStorm).

---

## Requirements

- **OS**: macOS / Linux.
- **Interpreters**: `bash`, `python3` (used by `git-flow.sh` for parsing and interactively modifying `pom.xml`).
- **Version File**: The target project's root directory must contain a `pom.xml` file with a `<projectVersion>X.Y.Z</projectVersion>` tag.

---

## Usage

### 1. Setting Up Run Configuration in IDE

You can automatically add the run configuration to your workspace using the `setup-run-config.sh` script:

```bash
./setup-run-config.sh /path/to/your/target/project
```

Once executed, an `assembly_on_preprod.xml` file will be created in `.idea/runConfigurations/` of the target project. The IDE will automatically detect the new run configuration named **"Assembly on preprod"**, which runs `git-flow.sh` in the context of your project.

### 2. Running the Script Directly from Terminal

The `git-flow.sh` script accepts an optional path to the target project directory (defaults to the current directory):

```bash
./git-flow.sh /path/to/your/target/project
```

Upon execution, the script prompts you to choose the version increment type:
```text
Current project version in pom.xml: 1.0.0

Select version increment option:
  1) Bump patch   (-> 1.0.1)
  2) Bump minor   (-> 1.1.0)
  3) Bump major   (-> 2.0.0)
  4) Enter manually

Select option (1-4):
```

After selecting or entering the new version, the script automatically performs merges and pushes the changes to the remote repository.

---

# GitScripts (RU)

Набор скриптов для автоматизации Git-workflow и интеграции с IDE WebStorm / PhpStorm / IntelliJ IDEA.

## Состав проекта

1. **`git-flow.sh`** — интерактивный Bash-скрипт для автоматизации процесса релиза:
   - Обновляет ветку `dev`.
   - Интерактивно повышает версию проекта в файле `pom.xml` (доступны варианты: патч, минор, мажор или ручной ввод) и делает коммит.
   - Обновляет локальную ветку `master` из `origin/master`.
   - Сливает `master` в `dev`.
   - Пушит `dev` в `origin`.
   - Переключается на `master` и сливает в него `dev`.
   - Пушит `master` в `origin`.
   
2. **`setup-run-config.sh`** — скрипт для быстрой настройки конфигурации запуска (Run Configuration) в вашей IDE:
   - Создает конфигурацию запуска под названием **«Assembly on preprod»** в указанном целевом проекте.
   - Позволяет запускать `git-flow.sh` прямо из интерфейса IDE (например, WebStorm).

---

## Требования

- **ОС**: macOS / Linux.
- **Интерпретаторы**: `bash`, `python3` (используется скриптом `git-flow.sh` для парсинга и интерактивного изменения `pom.xml`).
- **Файл версии**: В корневом каталоге целевого проекта должен присутствовать файл `pom.xml` с тегом `<projectVersion>X.Y.Z</projectVersion>`.

---

## Использование

### 1. Настройка конфигурации запуска в IDE

Вы можете автоматически добавить конфигурацию запуска в ваш рабочий проект с помощью скрипта `setup-run-config.sh`:

```bash
./setup-run-config.sh /путь/к/вашему/целевому/проекту
```

После этого в указанном проекте в каталоге `.idea/runConfigurations/` появится файл `assembly_on_preprod.xml`. IDE автоматически обнаружит новую конфигурацию запуска с именем **«Assembly on preprod»**, которая будет вызывать `git-flow.sh` в контексте вашего проекта.

### 2. Запуск скрипта напрямую через терминал

Скрипт `git-flow.sh` принимает в качестве необязательного аргумента путь к целевому проекту (по умолчанию используется текущая директория):

```bash
./git-flow.sh /путь/к/вашему/целевому/проекту
```

При запуске скрипт предложит выбрать тип инкремента версии:
```text
Текущая версия проекта в pom.xml: 1.0.0

Выберите действие с версией:
  1) Нарастить патч   (-> 1.0.1)
  2) Нарастить минор  (-> 1.1.0)
  3) Нарастить мажор  (-> 2.0.0)
  4) Задать вручную

Выберите опцию (1-4):
```

После выбора или ввода версии скрипт автоматически проведет слияния и отправит изменения в удаленный репозиторий.
