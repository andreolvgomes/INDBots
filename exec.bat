@echo off
set mensagem=%1
start /B curl -X GET "https://api.telegram.org/bot7549962155:AAGJObyGZv0N5VneszHuTwJGkmlreTo32dk/sendMessage?chat_id=484467891&text=%1"
exit
