#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "FATAL ERROR: Must run as root user ... "
  echo "Exiting..."
  exit
fi

#Docker  and dependencies 

#remove old versions
apt-get -y remove docker docker-engine docker.io containerd runc
apt-get -y update

apt-get -y install ca-certificates curl gnupg lsb-release git tigervnc-viewer make pip curl
    
    

curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get -y update
  apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin 

f=1
clear
printf "Enter desired name (not path) for skywater design folder: "
read -r sky_NAME

while [ $f -eq 1 ] ; do 
   printf "Enter desired path for design folder: "

    read -r design_PATH
    ## Remove spaces in case user added them
    design_PATH="$(echo "${design_PATH// /}")" 
    

    if ! [ -d "$design_PATH" ]; then
      echo "ERROR $design_PATH... DOES NOT EXIST"
    else 
       design_PATH="$(echo "$design_PATH/$sky_NAME/")" 
       f=0
     fi
done




printf "Enter password for logging into environment via vnc: "

read -r PASS

mkdir $design_PATH
 
export DESIGNS=$design_PATH
    
echo "## Adding shortcut to desktop... ###"
printf "\nEnter username of non root main user: "
read -r name

sed -i "1s/^/CHSN_PATH=$design_PATH\n /" ./EFABLESS 

sed -i "1s/^/CHSN_PASSWD=$PASS\n /" ./EFABLESS 

cp ./EFABLESS /home/$name/Desktop
chmod +x /home/$name/Desktop/EFABLESS
chown $name:$name /home/$name/Desktop/EFABLESS
  
clear
echo "#### Pulling efabless image, this make take a while ####" 
sleep 2
  
docker pull efabless/foss-asic-tools:latest
  
  
clear 
echo " #### Installing MPW Precheck  #### "
sleep 2

clear

f=1


while [ $f -eq 1 ] ; do 
   printf "Enter desired path for precheck folder: "

    read -r precheck_PATH
    ## Remove spaces in case user added them
    precheck_PATH="$(echo "${precheck_PATH// /}")" 
    

    if ! [ -d "$precheck_PATH" ]; then
      echo "ERROR $precheck_PATH... DOES NOT EXIST"
    else 
       f=0
     fi
done



cd $precheck_PATH
git clone -b mpw-7a https://github.com/efabless/caravel_user_project_analog
cd caravel_user_project_analog 
make install











 
