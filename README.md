## Deploy Zabbix Agent

Распространение конфигурации для шаблона **[Windows-User-Sessions](https://github.com/Lifailon/Windows-User-Sessions)**.

Применимо, если необходимо добавить новые параметры со скриптами или обновить текущую конфигурацию скрипта на всех машинах. Преполагается, что у вас уже установлен Zabbix Agent на всех серверах с эталонными путями, которые можно задать через параметры (**ключи: -PathAgent, -PathAgentConf, -PathAgentScriptFolder, -PathAgentScript**) или указать их в начале скрипта, а так же в файле **zabbix_agent2.conf** настроен параметр `Include=.\zabbix_agent2.d\plugins.d\*.conf` в формате **wildcard**.

Можно использовать свои списки серверов (используется по умолчанию, **ключ -ServerList .\Deploy-Server-List.txt**) или одни сервер (**ключ -Server**). Скрипт **проверяет доступность всех серверов (ping), WinRM и директории с агентом по пути**, после каждой впроверки пересобирает список доступных серверов, на всех серверах которые прошли проверки останавливает службу Zabbix Agent, в случае отсутствия директорий со скриптами, создает их, копирует **из репозиторизя GitHub** содержимое кинфигурационного файла и скрипта с параметрами, и запускает службу. Результат работы выводится на экран.

![Image alt](https://github.com/Lifailon/Deploy-Zabbix-Agent/blob/rsa/Example.jpg)
