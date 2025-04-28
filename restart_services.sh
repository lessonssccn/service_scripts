#!/bin/bash

# Флаг для принудительного режима (пропуск проверки активности)
FORCE_MODE=0

# Обработка аргументов командной строки
while getopts ":f" opt; do
  case $opt in
    f)
      FORCE_MODE=1
      ;;
    \?)
      echo "Неверный параметр: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

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

  # Если режим -f не активен, проверяем статус сервиса
  if [[ $FORCE_MODE -eq 0 ]]; then
    if ! systemctl is-active --quiet "$SERVICE_NAME"; then
      echo "Сервис '$SERVICE_NAME' не активен. Пропускаем."
      continue
    fi
  fi

  # Перезапуск сервиса
  echo "Перезапуск сервиса '$SERVICE_NAME'..."
  systemctl restart "$SERVICE_NAME"
  if [[ $? -eq 0 ]]; then
    echo "Сервис '$SERVICE_NAME' успешно перезапущен."
  else
    echo "Ошибка при перезапуске сервиса '$SERVICE_NAME'."
  fi
done

echo "Операция завершена."