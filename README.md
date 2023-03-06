## Deploy Zabbix Agent

Распространение конфигурации для шаблона **[Windows-User-Sessions](https://github.com/Lifailon/Windows-User-Sessions)**.

Применимо, если необходимо обновить текущую конфигурацию скрипта на всех машинах или добавить новые параметры и скрипты.

Преполагается, что у вам уже установлен Zabbix Agent на всех серверах с эталонными путями, которые можно задать через параметры (**ключи: -PathAgent, -PathAgentConf, -PathAgentScriptFolder, -PathAgentScript**) или задать их в начале скрипта, а так же в файле **zabbix_agent2.conf** настроен параметр `Include=.\zabbix_agent2.d\plugins.d\*.conf` в формате **wildcard**.

Можно использовать свои списки серверов (метод по умолчанию, **ключ -ServerList .\Deploy-Server-List.txt**) или одни сервер (**ключ -Server**). Вначале скрипт **проверяет доступность всех серверов (ping)**, после чего пересобирает список из доступных серверов, **проверяет доступность WinRM**, **проверяет доступность директории с агентом по пути**, на всех серверах, которые прошли проверки останавливает службу Zabbix Agent, в случае отсутствия директорий со скриптами, создает их, копирует содержимое кинфигурационного файла и скрипта с параметрами **из репозиторизя GitHub**, и запускает службу. Результат работы выводится на экран.

![Image alt](https://github.com/Lifailon/Deploy-Zabbix-Agent/blob/rsa/Example.jpg)
