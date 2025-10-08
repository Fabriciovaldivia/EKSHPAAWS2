#!/usr/bin/env bash

./stress-test.sh &
./stress-test-2.sh &
#ps aux | grep stress-test
#kill -9
# Opcional: esperar que ambos terminen antes de salir del script principal
wait
