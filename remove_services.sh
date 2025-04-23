#!/bin/bash

# Проверка прав доступа
if [[ $EUID -ne 0 ]]; then
  echo "Этот скрипт требует прав суперпользователя (sudo)."
  exit 1
fi

# Целевая директория для удаления символьных ссылок
TARGET_DIR="/etc/systemd/system"

# Поиск всех файлов с расширением .service в текущей директории
SERVICE_FILES=$(find . -maxdepth 1 -type f -name "*.service")

# Проверка, найдены ли файлы
if [[ -z "$SERVICE_FILES" ]]; then
  echo "Файлы с расширением .service не найдены в текущей директории."
  exit 0
fi

# Перебор всех найденных файлов
for SERVICE_FILE in $SERVICE_FILES; do
  # Имя файла без пути
  BASENAME=$(basename "$SERVICE_FILE")
  
  # Имя сервиса (без расширения)
  SERVICE_NAME="${BASENAME%.service}"
  
  # Путь к символьной ссылке
  TARGET_LINK="$TARGET_DIR/$BASENAME"
  
  # Проверка, существует ли символьная ссылка
  if [[ ! -L "$TARGET_LINK" ]]; then
    echo "Символьная ссылка для сервиса '$SERVICE_NAME' не найдена. Пропускаем."
    continue
  fi

  # Проверка статуса сервиса
  if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "Сервис '$SERVICE_NAME' активен. Удаление невозможно. Пропускаем."
    continue
  fi

  # Удаление символьной ссылки
  echo "Удаление символьной ссылки для сервиса '$SERVICE_NAME'..."
  rm -f "$TARGET_LINK"
  if [[ $? -eq 0 ]]; then
    echo "Символьная ссылка для сервиса '$SERVICE_NAME' успешно удалена."
  else
    echo "Ошибка при удалении символьной ссылки для сервиса '$SERVICE_NAME'."
  fi
done

# Обновление конфигурации systemd
echo "Обновление конфигурации systemd..."
systemctl daemon-reload
if [[ $? -ne 0 ]]; then
  echo "Ошибка при выполнении systemctl daemon-reload."
  exit 1
fi

echo "Операция завершена."