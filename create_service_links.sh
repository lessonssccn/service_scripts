#!/bin/bash

# Целевая директория для создания символьных ссылок
TARGET_DIR="/etc/systemd/system"

# Проверка прав доступа
if [[ $EUID -ne 0 ]]; then
  echo "Этот скрипт требует прав суперпользователя (sudo)."
  exit 1
fi

# Поиск всех файлов с расширением .service в текущей директории
SERVICE_FILES=$(find . -maxdepth 1 -type f -name "*.service" | sed 's|^\./||')

# Проверка, найдены ли файлы
if [[ -z "$SERVICE_FILES" ]]; then
  echo "Файлы с расширением .service не найдены в текущей директории."
  exit 0
fi

# Создание символьных ссылок
for SERVICE_FILE in $SERVICE_FILES; do
  # Имя файла без пути
  BASENAME=$(basename "$SERVICE_FILE")
  
  # Путь к целевой ссылке
  TARGET_LINK="$TARGET_DIR/$BASENAME"
  
  # Проверка существования ссылки
  if [[ -L "$TARGET_LINK" ]]; then
    echo "Ссылка '$TARGET_LINK' уже существует. Пропускаем."
  elif [[ -e "$TARGET_LINK" ]]; then
    echo "Файл '$TARGET_LINK' уже существует и не является ссылкой. Пропускаем."
  else
    # Создание символьной ссылки
    ln -s "$(pwd)/$SERVICE_FILE" "$TARGET_LINK"
    if [[ $? -eq 0 ]]; then
      echo "Создана ссылка: $TARGET_LINK -> $(pwd)/$SERVICE_FILE"
    else
      echo "Ошибка при создании ссылки для $SERVICE_FILE."
    fi
  fi
done

echo "Операция завершена."