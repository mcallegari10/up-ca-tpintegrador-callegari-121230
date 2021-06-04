#! /bin/bash

function mostrar_menu() {
  clear
  echo "1) Fibonacci"
  echo "2) Revertir un numero"
  echo "3) Palindromos"
  echo "4) Cantidad de lineas de archivo"
  echo "5) Ordenar numeros"
  echo "6) "
  echo "7) Salir"
}

function salir_saludando() {
    NOMBRE=$1
    echo "Chau $NOMBRE"
    sleep 2
}


option=0
mostrar_menu
while true; do
  read -p "Ingrese una opcion: " option
  case $option in
    1) echo "Ingrese una cantidad de numeros a mostrar: "
        read cant
        start=0
        next=1

        for ((i = 0; i < $cant; i++))
        do
          echo "$start"
          fibNext=$((start + next))
          start=$next
          next=$fibNext
        done;;

    2) echo "Ingrese un numero entero: "
        read num
        echo `echo ${num} | rev`;;

    # TODO: Sacar los espacios para soportar oraciones
    3) echo "Ingrese una cadena de caracteres: "
        read string_to_eval
        palidrome=0

        for ((i=0; i<${#string_to_eval}; i++)); do
          index_eval=$((${#string_to_eval} - i - 1))
          if [[ $i -gt $index_eval ]]; then
            break
          elif [[ ${string_to_eval:i:1} == ${string_to_eval:index_eval:1} ]]; then
            palidrome=1
          else
            palidrome=0
            break
          fi
        done

        if [[ $palidrome -eq 1 ]]; then
          echo " Es palindromo"
        else
          echo "No es palidromo"
        fi;;

    4) echo "Ingrese el path de un archivo: "
        read file
        echo "Cantidad de lineas del archivo: "
        echo `wc -l ${file}`;;

    5) echo "Ingrese 5 numeros enteros: "
        read -r first second third fourth fifth
        echo `echo -e "${first}\n${second}\n${third}\n${fourth}\n${fifth}" | sort -n`;;

    # TODO
    6) echo "Ingrese el path a un directorio: "

        ;;

    7) salir_saludando
        break;;

    *) echo "Opcion incorrecta";;
  esac
done
exit 0
