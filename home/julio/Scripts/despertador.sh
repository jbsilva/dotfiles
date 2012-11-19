#!/bin/bash

#############################################################################################################
#                                        Deixe o crontab assim:
#   minuto(0-59)    hora(0-23)    dia(1-31)     mes(1-12)      semana(0-6)              script
#       50              6           *              3-12            2,4           /home/julio/Scripts/despertador.sh
#       50              8           *              3-12            1,3           /home/julio/Scripts/despertador.sh
#############################################################################################################

#mpc toggle
ncmpcpp play

#END
