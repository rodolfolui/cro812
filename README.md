# cro812
IBM Resilency Orchestration 8.1.2 container

Introducción a IBM Resilency Orchestration 8.1.2
https://www.youtube.com/watch?v=YRKI2deypuI
Preparación de un ambiente de capacitación de CRO:
    1. Prepare una maquina virtual con RHEL 8.x (Linux Red Hat Enterprise) o con Ubuntu pero que tenga previamente instalado Docker
    1. Si tiene Apple Mac puede instalar docker para Mac y usar la linea de comandos
    2. Si tiene windows es un poco mas truculento usar docker para windows ya que debe seleccionar el entorno para linux y debe habilitar la virtualización de hyper-v, por lo que es mas sencillo usar VirtualBox y levantar una máquina con Ubuntu e instalar docker
    3. Si tiene instalado RHEL 8.x no requiere nada mas.  RHEL viene con podman instalado por defecto, podman es la versión de docker de RedHat y puede ser invocado mediante el comando docker.  Eso si en algunos casos  se va a requerir docker-compose para lo cual mas adelante vamos a explicar como instalar el podman-compose
    1. Importe y ejecute la imagen base de RHEL 8.2
    1. $ docker run -it --name cro -h crort -p 8080:8080 registry.access.redhat.com/ubi8/ubi:8.2 bash
    1. Instale las librerias
    1. [root@crort /]# dnf -y install hostname libXtst net-tools iputils procps-ng rsync sudo unzip wget
    1. Descargue el servidor de aplicaciones Tomcat 9.0.37 e instalelo en la ruta /opt
    1. [root@crort /]# wget -qO- https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.37/bin/apache-tomcat-9.0.37.tar.gz | tar -xzf - -C /opt
    1. Descargue los rpm's de instalación de la base de datos MariaDB 10.3.27 o del box CRO Server 8.1.2
    1. [root@crort /]# wget -qO- https://yum.mariadb.org/10.3/rhel8-amd64/rpms/MariaDB-server-10.3.27-1.el8.x86_64.rpm
    2. [root@crort /]# wget -qO- https://yum.mariadb.org/10.3/rhel8-amd64/rpms/MariaDB-client-10.3.27-1.el8.x86_64.rpm
    3. [root@crort /]# wget -qO- https://yum.mariadb.org/10.3/rhel8-amd64/rpms/galera-25.3.30-1.el8.x86_64.rpm
    4. [root@crort /]# wget -qO- https://yum.mariadb.org/10.3/rhel8-amd64/rpms/MariaDB-common-10.3.27-1.el8.x86_64.rpm
    1. Descarge el rpm de boost-program-options del box CRO Server 8.1.2
    2. Instale MariaDB, suba el servicio en el contenedor y cambie la contraseña por defecto
    1. [root@crort /]# rpm -Uvh boost-program-options-1.66.0-10.el8.x86_64.rpm
    2. [root@crort /]# dnf --disableplugin=subscription-manager install -y MariaDB-server galera MariaDB-client MariaDB-shared MariaDB-backup MariaDB-common
    3. [root@crort /]# /etc/init.d/mysql start
    4. [root@crort /]# mysqladmin -f -u root password 'Passw0rd'
    1. En otra ventana de linux por fuera del contenedor, copie el instalador del producto ubicado en Server.tar.gz dentro del contenedor asi:
    1. $ docker copy Server.tar.gz crort:/tmp
    1. Ejecute la instalación del producto siguiendo los pasos descritos en la guia de instalación de CRO a partir de la página 77 para el modo consola:
    1. [root@crort /]# cd tmp
    2. [root@crort /]# tar xvzf Server.tar.gz
    3. [root@crort /]# sed 's/LOCAL_HOST_SERVER=/LOCAL_HOST_SERVER=10.0.0.2/
    4. > s/DATABASE_PASSWORD=/DATABASE_PASSWORD=Passw0rd/
    5. > s/LICENSE_ACCEPTED=/LICENSE_ACCEPTED=TRUE/
    6. > s/SUPPORT_USER_PASSWORD=/SUPPORT_USER_PASSWORD=Orchestration123./
    7. > s/SANOVI_USER_PASSWORD=/SANOVI_USER_PASSWORD=Orchestration123./
    8. > s/MODIFY_SYSTEM_FILES=0/MODIFY_SYSTEM_FILES=1/
    9. > s/TOMCAT_HOME=.*/TOMCAT_HOME=\/opt\/apache-tomcat-9.0.37/' /tmp/PanacesServerInstaller.properties > /tmp/PanacesServerCro.properties
    10. [root@crort /]# /tmp/install.bin -f /tmp/PanacesServerCro.properties
    1. Ejecute los pasos post instalación descritos en la guia de instalación de CRO a partir de la página 85 (numeral 5.6) para el modo consola
    2. Inicie los servicios de CRO en el contenedor:
    1. export EAMSROOT=/opt/panaces
    2. /etc/init.d/mysql status || /etc/init.d/mysql start
    3. cd /opt/panaces/bin
    4. ./panaces restart
    1. Por último por fuera del contenedor en otra ventana, guarde una imagen del contenedor en ejecución para no perder la instalación (recuerden, los contenedores son por defecto no persistentes)
    1. $ docker commit crort cro812:latest
    1. Y listo! ya tenemos una imagen base de cro que podemos usar para nuestras capacitaciones
    1. $ docker images
REPOSITORY                           TAG             IMAGE ID      CREATED        SIZE
localhost/cro812                     latest          05fc28b5ad50  2 months ago   4.15 GB
