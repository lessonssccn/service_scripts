#!/bin/bash

# Получаем имя шаблона (первый .service-templ файл в текущей директории)
TEMPLATE=$(ls *.service-tmpl 2>/dev/null | head -n1)

if [[ -z "$TEMPLATE" ]]; then
  echo "❌ Шаблон .service-tmpl не найден в текущей директории"
  exit 1
fi

# Получаем информацию о текущем пользователе, пути и имени директории
CURRENT_USER=$(whoami)
CURRENT_PATH=$(pwd)
FOLDER_NAME=$(basename "$CURRENT_PATH")

# Преобразуем имя сервиса: _-., → пробел, затем каждое слово с заглавной буквы
SERVICE_NAME=$(echo "$FOLDER_NAME" | sed 's/[_\-\.]/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')

# Имя выходного файла: имя_папки.service
OUTPUT="${FOLDER_NAME}.service"

# Выполняем замену переменных и сохраняем в новый файл
sed -e "s/{{user}}/$CURRENT_USER/g" \
    -e "s|{{path}}|$CURRENT_PATH|g" \
    -e "s/{{name}}/$SERVICE_NAME/g" \
    "$TEMPLATE" > "$OUTPUT"

echo "✅ Сервис-файл создан: $OUTPUT"