#!/bin/bash

# Проверка прав доступа
if [[ $EUID -ne 0 ]]; then
  echo "Этот скрипт требует прав суперпользователя (sudo)."
  exit 1
fi

# Обновление конфигурации systemd
echo "Обновление конфигурации systemd..."
systemctl daemon-reload
if [[ $? -ne 0 ]]; then
  echo "Ошибка при выполнении systemctl daemon-reload."
  exit 1
fi

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
  
  # Проверка, зарегистрирован ли сервис в systemd
  if ! systemctl list-unit-files | grep -q "^$SERVICE_NAME.service"; then
    echo "Сервис '$SERVICE_NAME' не зарегистрирован в systemd. Пропускаем."
    continue
  fi

  # Проверка статуса сервиса
  if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "Сервис '$SERVICE_NAME' уже активен. Пропускаем."
    continue
  fi

  if systemctl is-enabled --quiet "$SERVICE_NAME"; then
    echo "Сервис '$SERVICE_NAME' уже включен. Пропускаем."
    continue
  fi

  # Включение и запуск сервиса
  echo "Включение и запуск сервиса '$SERVICE_NAME'..."
  systemctl enable "$SERVICE_NAME" && systemctl start "$SERVICE_NAME"
  if [[ $? -eq 0 ]]; then
    echo "Сервис '$SERVICE_NAME' успешно включен и запущен."
  else
    echo "Ошибка при включении или запуске сервиса '$SERVICE_NAME'."
  fi
done

echo "Операция завершена."