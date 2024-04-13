### MIKROTIK-AUTOMATITATIONS

### Características Principales:
1. **Interacción con Mikrotik:** El script se conecta a dispositivos Mikrotik a través de SSH para realizar diversas operaciones como filtrar datos, crear colas simples, realizar backups, enviar archivos, etc.

2. **Parámetros de Entrada:** El script acepta diferentes parámetros de entrada utilizando la función `getopts`. Los parámetros disponibles son:
   - `-u`: Nombre de usuario SSH.
   - `-i`: Dirección IP del dispositivo Mikrotik.
   - `-p`: Puerto SSH del dispositivo Mikrotik.
   - `-f`: Filtra datos de usuarios del servidor Mikrotik.
   - `-q`: Realiza la configuración para hacer PCQ (Per Connection Queue) con ráfagas.
   - `-b`: Realiza backups de equipos Mikrotik.
   - `-s`: Envía archivos al dispositivo Mikrotik.
   - `-r`: Muestra el panel de ayuda.

3. **Funciones Específicas:**
   - `filterData`: Filtra datos de usuarios en el servidor Mikrotik y los guarda en un archivo.
   - `queueSimple`: Configura colas simples en el dispositivo Mikrotik para controlar el ancho de banda.
   - `backupMikrotik`: Realiza backups del dispositivo Mikrotik.
   - `sendFile`: Envía archivos al dispositivo Mikrotik.

4. **Manipulación de Parámetros:** El script verifica los parámetros de entrada para determinar qué operación realizar y con qué dispositivo Mikrotik interactuar.


![image](https://github.com/Goh4nag0n/Mikrotik_Automatitations/assets/164566003/bf0f6ae1-d27f-4a11-a560-f898188168b5)
