#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m" 
LOG_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP"
validate() {
    if [ $1 -ne 0 ]
    then
      echo -e "$2....$R Failure $N"
      exit 1
     else
      echo  -e "$2..... $G Success $N" 
    fi  
}
check_root() {
  if [ $USERID -ne 0 ]
   then
    echo -e " Erorr:$R Only Root user access this script $N "
   exit 1
 fi
}
mkdir -p /var/log/expense-logs
check_root
dnf module disable nodejs -y &>>$LOG_FILE_NAME
validate $? "Disabling existing  nodejs"
dnf module enable nodejs:20 -y   &>>$LOG_FILE_NAME
validate $? "Enabling   nodejs version 20"
dnf install nodejs -y &>>$LOG_FILE_NAME
validate $? "Installing nodejs "
id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
    useradd expense &>>$LOG_FILE_NAME
    validate $? "Adding expense user"
else
    echo -e "expense user already exists ... $Y SKIPPING $N"
fi
mkdir /app &>>$LOG_FILE_NAME
validate $? "creating app directory" 
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
validate $? "downloading the application"
cd /app
unzip /tmp/backend.zip &>>$LOG_FILE_NAME
validate $? "unzipping the application"
npm install  &>>$LOG_FILE_NAME &>>$LOG_FILE_NAME
validate $? "Installing the dependencies"
cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE_NAME
dnf install mysql -y &>>$LOG_FILE_NAME
validate $? "Installing mysql client" 
mysql -h mysql.daws82s.cloud -uroot -pExpenseApp@1 < /app/schema/backend.sql  &>>$LOG_FILE_NAME
validate $? "Setting up the transaction schema and table "
systemctl daemon-reload  &>>$LOG_FILE_NAME
validate $? "daemon reloading "
systemctl enable backend  &>>$LOG_FILE_NAME
validate $? "Enabling the backend server"
systemctl start backend  &>>$LOG_FILE_NAME
validate $? "start backend"