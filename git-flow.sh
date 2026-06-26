#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0;0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Target directory handling (defaults to current directory if not specified)
TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
    log_error "Directory '$TARGET_DIR' does not exist."
    exit 1
fi

# Change to the target directory
cd "$TARGET_DIR"
log_info "Working directory set to: $(pwd)"

# Verify we are in a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    log_error "This script must be run inside a Git repository."
    exit 1
fi

# Ensure pom.xml exists in the current directory
if [ ! -f "pom.xml" ]; then
    log_error "pom.xml not found in the target directory: $(pwd)"
    exit 1
fi

log_info "Starting Git workflow..."

# 1. git checkout dev
log_info "Step 1: Checking out dev branch..."
git checkout dev

# 2. git pull
log_info "Step 2: Pulling latest changes for dev..."
git pull

# 3. git update origin dev -> mapping to git fetch origin dev
log_info "Step 3: Fetching origin dev (git update origin dev)..."
git fetch origin dev

# Increment version in pom.xml (Interactive Selection)
log_info "Prompting for version bump selection..."
temp_file=$(mktemp)

# Run python in-place to prompt user and write to pom.xml and temp_file
python3 -c "
import sys
import re

temp_path = sys.argv[1]
pom_path = 'pom.xml'

try:
    with open(pom_path, 'r', encoding='utf-8') as f:
        content = f.read()
except Exception as e:
    print(f'Ошибка при чтении pom.xml: {str(e)}')
    sys.exit(1)

pattern = r'(<projectVersion>)(\d+)\.(\d+)\.(\d+)(</projectVersion>)'
match = re.search(pattern, content)
if not match:
    print('Ошибка: <projectVersion> не найден в pom.xml или имеет неверный формат')
    sys.exit(1)

major, minor, patch = int(match.group(2)), int(match.group(3)), int(match.group(4))
current_version = f'{major}.{minor}.{patch}'

patch_ver = f'{major}.{minor}.{patch + 1}'
minor_ver = f'{major}.{minor + 1}.0'
major_ver = f'{major + 1}.0.0'

print(f'\nТекущая версия проекта в pom.xml: \033[1;32m{current_version}\033[0m')
print('\nВыберите действие с версией:')
print(f'  1) Нарастить патч   (-> {patch_ver})')
print(f'  2) Нарастить минор  (-> {minor_ver})')
print(f'  3) Нарастить мажор  (-> {major_ver})')
print('  4) Задать вручную')

try:
    choice = input('\nВыберите опцию (1-4): ').strip()
    if choice == '1':
        new_version = patch_ver
    elif choice == '2':
        new_version = minor_ver
    elif choice == '3':
        new_version = major_ver
    elif choice == '4':
        new_version = input('Введите новую версию вручную (например, 56.23.1): ').strip()
        if not re.match(r'^\d+\.\d+\.\d+$', new_version):
            print('\033[0;31mОшибка: Неверный формат версии. Должен быть X.Y.Z\033[0m')
            sys.exit(1)
    else:
        print('\033[0;31mОшибка: Неверный выбор.\033[0m')
        sys.exit(1)
except (KeyboardInterrupt, EOFError):
    print('\n\033[0;33mВыполнение отменено пользователем.\033[0m')
    sys.exit(1)

try:
    new_content = re.sub(pattern, rf'\g<1>{new_version}\g<5>', content)
    with open(pom_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
except Exception as e:
    print(f'Ошибка при записи в pom.xml: {str(e)}')
    sys.exit(1)

try:
    with open(temp_path, 'w', encoding='utf-8') as f:
        f.write(f'{current_version}\n{new_version}')
except Exception as e:
    print(f'Ошибка при записи во временный файл: {str(e)}')
    sys.exit(1)

print(f'\n\033[1;32mУспешно обновлено до версии {new_version}!\033[0m\n')
" "$temp_file"

if [ $? -ne 0 ]; then
    log_error "Version bumping was cancelled or failed."
    rm -f "$temp_file"
    exit 1
fi

{
    read -r OLD_VERSION
    read -r NEW_VERSION
} < "$temp_file"
rm -f "$temp_file"


# Commit the version bump
log_info "Committing the version bump..."
git commit -am "update pom.xml $OLD_VERSION -> $NEW_VERSION"

# 4. git update origin master -> mapping to git fetch origin master:master
log_info "Step 4: Updating local master branch from origin (git update origin master)..."
# If local master doesn't exist, we fetch master from origin
if ! git show-ref --verify --quiet refs/heads/master; then
    log_warning "Local master branch does not exist. Creating it from origin/master..."
    git fetch origin master:master
else
    # Update local master branch directly (will only succeed if it can be fast-forwarded)
    if ! git fetch origin master:master; then
        log_warning "Could not fast-forward local master branch from origin/master."
        log_warning "Attempting to checkout master, pull, and checkout dev back..."
        git checkout master
        git pull origin master
        git checkout dev
    fi
fi

# 5. git merge master
log_info "Step 5: Merging master into dev..."
git merge master

# 6. git push origin dev
log_info "Step 6: Pushing dev to origin..."
git push origin dev

# 7. git checkout master
log_info "Step 7: Checking out master branch..."
git checkout master

# 8. git merge dev
log_info "Step 8: Merging dev into master..."
git merge dev

# 9. git push origin master
log_info "Step 9: Pushing master to origin..."
git push origin master

log_success "Workflow completed successfully!"
log_info "Currently on branch: $(git branch --show-current)"
