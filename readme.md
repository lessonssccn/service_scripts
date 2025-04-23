# Небольшая помошь при создании демонов(сервисов) через systemd
Запускать из парки где лежат файлы *.service
- create_service_links.sh - создает символь ссылки на все файлы *.service которые лежат в текущей папке, перед созданием проверяет наличие ссылок и файлов с таким же именем в /etc/systemd/system
- start_services.sh - выполняет systemctl enable и systemctl start для каждого файла *.service лежащего в текщей папке и для которого были созданы символьные сслыки в /etc/systemd/system (запускает сервис) (есть провекри сервисы is-active и is-enabled пропускаються)
- restart_services.sh - аналогично start_services, но выполянет systemctl restart
- stop_services.sh - аналогично start_services, но выполянет systemctl stop
- remove_services.sh - удаляет символьные ссылки на файлы *.service из текущей папке в /etc/systemd/system
### Что проверенно в работе 
- create_service_links.sh
- start_services.sh 
- remove_services.sh 

