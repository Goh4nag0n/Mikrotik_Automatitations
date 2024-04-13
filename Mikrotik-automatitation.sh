#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


trap ctrl_c INT 
function ctrl_c (){
  echo -e "\n\n Saliendo..."
  exit 1
}

function helpPanel (){
  clear
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
  echo -e "\t${blueColour}u)${endColour}${grayColour} Usuario para conexion ssh${endColour}"
  echo -e "\t${blueColour}i)${endColour}${grayColour} direccion ipv4 del router Mikrotik${endColour}"
  echo -e "\t${blueColour}p)${endColour}${grayColour} puerto ssh${endColour}"
  echo -e "\t${blueColour}f)${endColour}${grayColour} Filtramos la data de los usuarios del servidor Mikrotik${endColour} ${purpleColour}->${endColour}"
  echo -e "\t${redColour}(-f -u usuario -i direccion -p puerto)${endColour}"
  echo -e "\t${blueColour}q)${endColour}${grayColour} hacer pcq con rafagas, generar colas simples determinar y verificar si hay colas previamente creadas${endColour}${purpleColour} ->${endColour}"
  echo -e "\t${redColour}(-q -u usuario -i direccion -p puerto)${endColour}"
  echo -e "\t${blueColour}b)${endColour}${grayColour} hacer backups de equipos Mikrotik ${endColour}${purpleColour} ->${endColour}"   
  echo -e "\t${redColour}(-b -u usuario -i direccion -p puerto)${endColour}"
  echo -e "\t${blueColour}s)${endColour}${grayColour} Enviar archivos al Mikrotik en caso de ser necesario que sea backup recordar ponerle de nombre de subida .rsc${endColour}${purpleColour} ->${endColour}"
  echo -e "\t${redColour}(-s -u usuario -i direccion -p puerto)${endColour}"
}



function activeSSHConnection(){

    if [ "$port" == 22 ]; then 
      loginSsh="ssh $user@$ip"
      if $loginSsh interface print > /dev/null 2>&1; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} La conexion fue exitosa con el siguiente comando...${endColour} ${purpleColour}->${endColour} ${blueColour}[ssh $user@$ip]${endColour}"
        sleep 2
        clear

      else 
        echo -e "\n${redColour}[!] Usuario o clave erroneo${endColour}"
        exit 1
      fi
    else
      loginSsh="ssh -p $port $user@$ip"
      if $loginSsh interface print > /dev/null 2>&1; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} La conexion fue exitosa con el siguiente comando...${endColour}${purpleColour} ->${endColour} ${blueColour}[ssh $user@$ip -p $port]${endColour}"
        sleep 2
        clear
      else
        echo -e "\n${redColour}[!] Usuario o clave erroneo${endColour}"
        exit 1
      fi
    fi
}

function checkSSHConnection(){
  while true; do
    if [ "$port" == 22 ]; then
      loginSsh="sshpass -p "$password" ssh $user@$ip" 
      if $loginSsh interface print >/dev/null 2>&1; then

        echo -e "\n${yellowColour}[+]${endColour}${grayColour} La clave es correcta...${endColour}"
        sleep 2
        comando="sshpass -p $password ssh $user@$ip"
        comando2="sshpass -p $password scp $user@$ip"
        comando3="sshpass -p $password scp -r ./$archivo2 $user@$ip:$archivo3"
        break
      else
        echo -e "\n${redColour}[!] La clave es erronea...${endColour}"
        echo -e "\n${yellowColour}\n[+]${endColour}${grayColour} Almacenar clave${endColour}${purpleColour} ->${endColour}"&& read password
      fi
    else
      loginSsh="sshpass -p "$password" ssh -p $port $user@$ip" 
      if $loginSsh interface print >/dev/null 2>&1; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} La clave es correcta...${endColour}"
        sleep 2
        comando="sshpass -p $password ssh $user@$ip -p $port"
        comando2="sshpass -p $password scp -P $port $user@$ip"
        comando3="ssshpass -p $password scp -P $port -r ./$archivo2 $user@$ip:$archivo3"
        break
      else
        echo -e "\n${redColour}[!] La clave es erronea...${endColour}"
        echo -e "\n${yellowColour}\n[+]${endColour}${grayColour} Almacenar clave${endColour}${purpleColour} ->${endColour}"&& read password
      fi
    fi
  done
}

function keySsh (){
  sshfile=~/.ssh/id_rsa.pub

  if  ls $sshfile > /dev/null 2>&1; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} ya tienes las llaves del equipo...${endColour}"
  else 
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Creando llaves publicas y privadas...${endColour}\n"
    ssh-keygen -t rsa
  fi
  if [ $port -eq 22 ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} quieres subir la llave publica al mikrotik o ya la tienes implementada?${endColour}\n" && read respuesta
    while true; do
      if [ $respuesta == "si" ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} como quieres que se llame la llave?${endColour}" && read keypublic
        scp ${sshfile} $user@$ip:/$keypublic.pub
        ssh $user@$ip /user ssh-keys import public-key-file=$keypublic.pub user=$user
        break 
      elif [ $respuesta == "no" ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Sigamos con el codigo...${endColour}\n"
        break
      else
        echo -e "${redColour}[!]solo se puede responder con si o no en minusculas...${endColour}"
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} quieres subir la llave publica al mikrotik o ya la tienes implementada?${endColour}\n" && read respuesta
      fi
    done

    comando="ssh $user@$ip"
    comando2="scp $user@$ip" 
    comando3="scp -r ./$archivo2 $user@$ip:$archivo3"

  else
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} quieres subir la llave publica al mikrotik o ya la tienes implementada?${endColour}\n" && read respuesta
    while true; do
      if [ $respuesta == "si" ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} como quieres que se llame la llave?${endColour}" && read keypublic
        scp -P $port ${sshfile} $user@$ip:/$keypublic.pub
    ssh $user@$ip -p $port /user ssh-keys import public-key-file=$keypublic.pub user=$user
        break 
      elif [ $respuesta == "no" ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Sigamos con el codigo...${endColour}\n"
        break
      else
        echo -e "${redColour}[!]solo se puede responder con si o no en minusculas...${endColour}"
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} quieres subir la llave publica al mikrotik o ya la tienes implementada?${endColour}\n" && read respuesta
      fi
    done

    comando="ssh -p $port $user@$ip"
    comando2="scp -P $port $user@$ip" 
    comando3="scp -P $port -r ./$archivo2 $user@$ip:$archivo3"

  fi
}


function verifyQueuesimple(){
  #verificar si hay colas simples creadas
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Verificamos si tienes colas simples creadas...${endColour}"
  if [ "$port" == 22 ]; then

    sshpass -p "$password" ssh $user@$ip queue simple print file=colasenequipo.txt
    sshpass -p "$password" scp $user@$ip:/colasenequipo.txt .

    archivo=colasenequipo.txt
    bytes=$(stat -c %s $archivo)

    if [ $bytes -gt 117 ]; then

      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Tienes colas simples en el equipo...${endColour}"

      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Quieres borrar el contenido de queue simple (si o no)?${endColour}" && read sino 
      while true; do
        if [ "$sino" == si ]; then

          echo -e "\n${yellowColour}[+]${endColour}${grayColour} Borrando las colas en el equipo...${endColour}"
          sshpass -p "$password" ssh $user@$ip queue simple remove [find]
          break

        elif [ "$sino" == no ]; then
          echo -e "\n${yellowColour}[+]${endColour}${grayColour} Seguimos con el flujo del programa${endColour}"
          break
        else
          echo -e "${redColour}[!] Solo puedes responder con si o no en minusculas${endColour}"
          
          echo -e "\n${yellowColour}[+]${endColour}${grayColour} Quieres borrar el contenido de queue simple (si o no)?${endColour}" && read sino 
        fi
      done
    elif [ $bytes -eq 114 ]; then
      
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} No hay contenido en el archivo:${endColour}"
     
    elif [ $bytes -eq 117 ]; then
      
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} No hay contenido en el archivo:${endColour}"
     
    fi

  else
    sshpass -p "$password" ssh -p $port $user@$ip queue simple print file=colasenequipo
    sshpass -p "$password" scp -P $port $user@$ip:/colasenequipo.txt .
    
    archivo=colasenequipo.txt
    bytes=$(stat -c %s $archivo) 
    if [ $bytes -gt 117 ]; then

      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Tienes colas simples en el equipo...${endColour}"

      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Quieres borrar el contenido de queue simple (si o no)?${endColour}" && read sino 
      while true; do
        if [ "$sino" == si ]; then

          echo -e "\n${yellowColour}[+]${endColour}${grayColour} Borrando las colas en el equipo...${endColour}"
          sshpass -p "$password" ssh -p $port $user@$ip queue simple remove [find]
          break

        elif [ "$sino" == no ]; then
          echo -e "\n${yellowColour}[+]${endColour}${grayColour} Seguimos con el flujo del programa${endColour}"
          break
        else
          echo -e "${redColour}[!] Solo puedes responder con si o no en minusculas${endColour}"
          
          echo -e "\n${yellowColour}[+]${endColour}${grayColour} Quieres borrar el contenido de queue simple (si o no)?${endColour}" && read sino 
        fi
      done
    elif [ $bytes -eq 117 ]; then
      
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} No hay contenido en el archivo:${endColour}"

    else
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} No hay contenido en el archivo:${endColour}"
    
    fi
  fi 
  rm $archivo
}

function reusoQueuing (){
  echo -e "${yellowColour}[+]${endColour}${grayColour} Cuanto ancho de banda tienes en la red?${endColour}"&& read total
  echo -e "${yellowColour}[+]${endColour}${grayColour} Cuantos planes tienes?${endColour}"&& read number1

  total_megas=0
  for ((i=1; i<=$number1; i++)); do
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Cuantos megas equivale el plan?${endColour}"&& read plan
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Cuantos usuarios tiene este plan?${endColour}"&& read user 
    cantidad=$(($plan * $user))
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Tienes que tener un total ${endColour}${greenColour}${cantidad}M${endColour}${grayColour} para tener 1 mega por cada usuario de este plan${endColour}"
    sleep 2
    total_megas=$(($total_megas + $cantidad))
    sleep 1
  done
  reuso=$(echo "scale=2; $total_megas / $total" | bc)  
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} tu reuso es de ${endColour}${purpleColour}$reuso${endColour}${grayColour} por usuario${endColour}"

}

function filterData (){
  user=$1
  ip=$2
  port=$3
  
  echo -e "${yellowColour}[+]${endColour} Si es v7 puedes logearte sin clave con llave privada y publica quieres ingresar de esta forma?\n"&& read respuesta 
  while true; do 
    if [ $respuesta == "si" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} procedemos a enviar los comandos...${endColour}"
      keySsh
      break
    elif [ $respuesta == "no" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} por la manera tradicional...${endColour}"
      activeSSHConnection

      echo -e "${yellowColour}\n[+]${endColour} ${grayColour}Almacenar clave${endColour}${purpleColour} ->${endColour}"&& read password

      checkSSHConnection
      break
    else
      echo -e "\n${redColour}[!] solo puedes responder con si o no en minusculas...${endColour}"

      echo -e "\n${yellowColour}[+]${endColour} Si es v7 puedes logearte sin clave con llave privada y publica quieres ingresar de esta forma?\n"&& read respuesta     
    fi
  done
  
  clear

  echo -e "${yellowColour}\n[+]${endColour}${grayColour} Que lista quieres descargar del mikrotik${endColour}${purpleColour} ->${endColour}"&& read address_list
  echo -e "${yellowColour}\n[+]${endColour}${grayColour} en que archivo quieres que guarde la data${endColour}${purpleColour} ->${endColour}"&& read file
  echo -e "\n${yellowColour}\n[+]${endColour}${grayColour} filtrando data en mikrotik...${endColour}"
  
  $comando ip firewall address-list print file=$file where list=$address_list
  echo -e "\n${yellowColour}\n[+]${endColour}${grayColour} Descargando data...${endColour}"
  $comando2:/$file.txt .
  echo -e "\n${yellowColour}\n[+]${endColour}${grayColour} Filtramos y guardamos la informacion importante...${endColour}"

  cat $file.txt | awk 'NR>5 {print $4}' | sponge $file.txt
}

function queueSimple (){
  user=$1
  ip=$2
  port=$3
  clear

  echo -e "${yellowColour}[+]${endColour} Si es v7 puedes logearte sin clave con llave privada y publica quieres ingresar de esta forma?\n"&& read respuesta 
  while true; do 
    if [ $respuesta == "si" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} procedemos a enviar los comandos...${endColour}"
      keySsh
      break
    elif [ $respuesta == "no" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} por la manera tradicional...${endColour}"
      activeSSHConnection
      echo -e "${yellowColour}\n[+]${endColour} ${grayColour}Almacenar clave${endColour}${purpleColour} ->${endColour}"&& read password
      checkSSHConnection
      break
    else
      echo -e "\n${redColour}[!] solo puedes responder con si o no en minusculas...${endColour}"

      echo -e "\n${yellowColour}[+]${endColour} Si es v7 puedes logearte sin clave con llave privada y publica quieres ingresar de esta forma?\n"&& read respuesta     
    fi
  done

  clear

  #DEFINIR RAFAGAS Y COLAS
  echo -e "${yellowColour}[+]${endColour}${grayColour} Cuanto es lo minimo que quieres que naveguen los usuarios...${endColour}"&& read pcqRate
  

  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Vamos a crear el pcq para las rafagas, primero el threshold...${endColour}"&& read thresHold
  
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} segundo el Burst-time...${endColour}" && read burstTime

  echo -e "\n${yellowColour}[+]${endColour}${grayColour} por ultimo el Burst-limit...${endColour}" && read burstLimit  
  segundos=$((($burstTime * $thresHold)/$burstLimit))

  echo -e "\n${yellowColour}[+]${endColour}${grayColour} La rafaga es de $segundos segundos....${endColour}"
  
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Estas de acuerdo con esta configuracion (si o no)?${endColour}" && read respuesta

  while true; do
    if [ "$respuesta" == "si" ]; then
      
      thresHold="$thresHold"M
      burstLimit="$burstLimit"M
      pcqRate="$pcqRate"M

      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Nombre de la cola${endColour}" && read nombre

      nombredescarga="$nombre-DOWN"
      nombresubida="$nombre-UP"

      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Asi queda la descarga${endColour}${purpleColour} ->${endColour}${greenColour} add kind=pcq name="$nombredescarga" pcq-burst-rate=$burstLimit pcq-burst-threshold=$thresHold pcq-burst-time=$burstTime pcq-classifier=dst-address pcq-rate=$pcqRate ${endColour}"

      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Asi queda la subida${endColour}${purpleColour} ->${endColour}${greenColour} add kind=pcq name="$nombresubida" pcq-burst-rate=$burstLimit pcq-burst-threshold=$thresHold pcq-burst-time=$BurstTime pcq-classifier=src-address pcq-rate=$pcqRate ${endColour}"
      
    $comando queue type add kind=pcq name="$nombredescarga" pcq-burst-rate=$burstLimit pcq-burst-threshold=$thresHold pcq-burst-time=$burstTime pcq-classifier=dst-address pcq-rate=$pcqRate

    $comando queue type add kind=pcq name="$nombresubida" pcq-burst-rate=$burstLimit pcq-burst-threshold=$thresHold pcq-burst-time=$burstTime pcq-classifier=src-address pcq-rate=$pcqRate      

    break

    elif [ "$respuesta" == "no" ]; then
      echo -e "${yellowColour}[+]${endColour}${grayColour} Cuanto es lo minimo que quieres que naveguen los usuarios${endColour}"&& read pcqRate

      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Vamos a crear el pcq para las rafagas, primero el Threshold${endColour}"&& read thresHold
  
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} segundo el Burst-time${endColour}" && read burstTime

      echo -e "\n${yellowColour}[+]${endColour}${grayColour} por ultimo el Burst-limit${endColour}" && read burstLimit  
  segundos=$((($burstTime * $thresHold)/$burstLimit))

      echo -e "\n${yellowColour}[+]${endColour}${grayColour} La rafaga es de $segundos segundos...${endColour}"
  
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Estas de acuerdo con esta configuracion (si o no)?${endColour}" && read respuesta
    #si coloca algo distinto de si o no
    else
      
      echo -e "\n${redColour}[!] solo puedes responder con si o no en minusculas${endColour}"
      
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Estas de acuerdo con esta configuracion (si o no)?${endColour}" && read respuesta

    fi
  done

  verifyQueuesimple

  #creamos cola simple 
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Archivos en carpeta....${endColour}\n"
  
  ls -l

  echo -e "${yellowColour}\n[+]${endColour}${grayColour} Cual es el archivo con el que vamos a crear las colas${endColour} ->"&& read file

  while true; do 
    if [ -s "$file" ]; then 
      break 
    else 
      echo -e "\n${redColour}[!] El archivo no existe o no tiene contenido...${endColour}"

      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Si no tienes ningun archivo debes primero ejecutar la funcion ${endColour}${blueColour}filterData${endColour}${redColour} (pon CTRL+C para detener el flujo del programa y empezar de nuevo)${endColour}"

      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Archivos en carpeta....${endColour}\n"
  
      ls -l

      echo -e "${yellowColour}\n[+]${endColour}${grayColour} Cual es el archivo con el que vamos a crear las colas${endColour} ->"&& read file
    fi
  done


  #AQUI INSERTAMOS LA COLAS EN LE MIKROTIK
  touch colas.txt
  colas=colas.txt
  declare -i cantidad=0

  while read line; do 

    echo -e "${yellowColour}[+]${endColour}${grayColour} Insertando cola con la siguiente ip:${endColour}${blueColour} $line ${endColour}"
    sleep 0.2
    let cantidad+=1
 
    if [ "$port" == 22 ]; then
      colaSimples="$comando queue simple add queue=\"$nombresubida/$nombredescarga\" target=\"$line\" name=\"$line\""
      echo "$colaSimples" >> "$colas"

    else
      colaSimples="$comando queue simple add queue=\"$nombresubida/$nombredescarga\" target=\"$line\" name=\"$line\"" 
      echo "$colaSimples" >> "$colas"

    fi

  done < $file

  tput civis
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Estamos ingresando un total de${endColour}${blueColour} $cantidad${endColour}${grayColour} colas${endColour}"
  sleep 5
  clear
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Empezamos a ingresar las colas por favor paciencia...${endColour}"
  bash colas.txt
  tput cnorm
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Se t:erminaron de crear las colas....${endColour}"
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Borramos archivos residuales...${endColour}" 
  rm $file
  rm $colas
}

function backupMikrotik(){
  user=$1
  ip=$2
  port=$3
  clear

  activeSSHConnection

  echo -e "${yellowColour}\n[+]${endColour} ${grayColour}Almacenar clave${endColour}${purpleColour} ->${endColour}"&& read password
  checkSSHConnection
   
  mkdir backups
  cd backups
  echo -e "${yellowColour}[+]${endColour}${grayColour} Que version es tu mikrotik (6 o 7)?${endColour}"&& read version 

  while true; do
    if [ "$version" == "6" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Como quieres que se llame el backup:${endColour}\n"&& read nombre 
      sshpass -p "$password" $comando export file=$nombre
      sshpass -p "$password" $comando2:/$nombre.rsc . 
      
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Esta listo el backup...${endColour}"
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Quieres subir el backup al mikrotik? (si o no)...${endColour}"&& read respuesta
      break
    elif [ "$version" == "7" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Como quieres que se llame el backup:${endColour}\n"&& read nombre 
      sshpass -p "$password" $comando export show-sensitive file=$nombre
      sshpass -p "$password" $comando2:/$nombre.rsc . 
      
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Esta listo el backup...${endColour}"
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Quieres subir el backup al mikrotik? (si o no)...${endColour}"&& read respuesta
      break
    else 
      echo -e "${redColour}[!] Version erronea....${endColour}"

      echo -e "${yellowColour}[+]${endColour}${grayColour} Que version es tu mikrotik (6 o 7)?${endColour}"&& read version 
    fi
  done


}

function sendFile (){
  user=$1 
  ip=$2 
  port=$3

  activeSSHConnection

  echo -e "${yellowColour}\n[+]${endColour} ${grayColour}Almacenar clave${endColour}${purpleColour} ->${endColour}"&& read password
  checkSSHConnection

  ls -l

  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Que archivo quieres subir?${endColour}"&& read archivo2
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Que nombre le vas a poner al archivo en el mikrotik? (.rsc si es un backup)${endColour}"&& read archivo3 
  while true; do
    if [ -s $archivo2 ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Subiendo archivo...${endColour}"
      sleep 3
      if [ "$port" == "22"]; then
        sshpass -p "$password" scp -r ./$archivo2 $user@$ip:$archivo3       
      else
        sshpass -p "$password" scp -P $port -r ./$archivo2$user@$ip:$archivo3
      fi
      break 
    else 
      echo -e "\n${redColour}[!] No tiene contenido o no exite el archivo...${endColour}"
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Que archivo quieres subir?${endColour}"&& read archivo2
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Que nombre le vas a poner al archivo en el mikrotik? (.rsc si es un backup)${endColour}"&& read archivo3 
    fi
  done

}
#contadores
declare -i chivato_ip=0
declare -i chivato_user=0
declare -i parameter_counter=0
declare -i chivato_port=0

#opciones y argumentos
while getopts "u:i:fqhbsrp:" arg; do 
  case $arg in
    u) user=$OPTARG;;
    i) ip=$OPTARG;;
    p) port=$OPTARG;;
    f) chivato_user=1; chivato_ip=1; chivato_port=1; let parameter_counter+=1 ;;
    q) chivato_user=1; chivato_ip=1; chivato_port=1; let parameter_counter+=2 ;;
    b) chivato_user=1; chivato_ip=1; chivato_port=1; let parameter_counter+=3 ;;
    s) chivato_user=1; chivato_ip=1; chivato_port=1; let parameter_counter+=4 ;;
    r) let parameter_counter+=5 ;;
    h) ;;
  esac
done

#programa principal
if [ $parameter_counter -eq 1 ] && [ $chivato_user -eq 1 ] && [ $chivato_ip -eq 1 ] && [ $chivato_port -eq 1 ]; then
  filterData $user $ip $port
elif [ $parameter_counter -eq 2 ] && [ $chivato_user -eq 1 ] && [ $chivato_ip -eq 1 ] && [ $chivato_port -eq 1 ]; then
  queueSimple $user $ip $port
elif [ $parameter_counter -eq 3 ] && [ $chivato_user -eq 1 ] && [ $chivato_ip -eq 1 ] && [ $chivato_port -eq 1 ]; then
  backupMikrotik $user $ip $port
elif [ $parameter_counter -eq 4 ] && [ $chivato_user -eq 1 ] && [ $chivato_ip -eq 1 ] && [ $chivato_port -eq 1 ]; then
  sendFile $user $ip $port
elif [ $parameter_counter -eq 5 ]; then
  reusoQueuing 
else
  helpPanel 
fi
