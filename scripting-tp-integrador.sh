#! /bin/bash

function mostrar_menu() {
  clear
  echo "1) Fibonacci"
  echo "2) Revertir un numero"
  echo "3) Palindromos"
  echo "4) Cantidad de lineas de archivo"
  echo "5) Ordenar numeros"
  echo "6) Tipos de archivos en path"
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

    3) echo "Ingrese una cadena de caracteres: "
        read string_to_eval
        string_to_eval=`echo "${string_to_eval}" | sed 's/ //g'`
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

    6) echo "Ingrese el path a un directorio: "
        read path
        common=0
        file_types=`ls -la ${path} | cut -c 1 | tail -n +2`
        
        for type in $file_types; do
          count=`echo "$file_types" | grep -c ${type}`
          if [[ $type == "-" ]]; then
            common=$count
          else
            printf -v "${type}" "%s" ${count}
          fi
        done

        echo "Tipos de archivos: "
        echo "Comunes: ${common}"
        echo "Directorios: ${d}"
        echo "Links: ${l}"
        echo "Dispositivos de caracteres: ${c}"
        echo "Bloques: ${b}"
        echo "Pipes: ${p}"
        echo "Sockets: ${s}";;

    7) salir_saludando `whoami`
        break;;

    *) echo "Opcion incorrecta";;
  esac
done
exit 0
