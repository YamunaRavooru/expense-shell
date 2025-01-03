#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m" 
LOG_FOLDER="/var/log/shellscript-logs"
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
check-root() {
  if [ $USERID -ne 0 ]
   then
    echo -e " Erorr:$R Only Root user access this script $N "
   exit 1
 fi
}
mkdir -p /var/log/expense-logs
echo "Script started executing at :$TIMESTAMP" &>>$LOG_FILE_NAME
check_root 
dnf install nginx -y &>>$LOG_FILE_NAME
validate $? "installing nginx"
systemctl enable nginx &>>$LOG_FILE_NAME
validate $? "Enabling nginx"
systemctl start nginx &>>$LOG_FILE_NAME
validate $? "Starting the nginx"
rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
validate $? "removing existing version of code"
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
validate $? "Downloading new code"
cd /usr/share/nginx/html  &>>LOG_FILE_NAME
validate $? "moving to html directory"
unzip /tmp/frontend.zip &>>LOG_FILE_NAME
validate $? "unzipping the code "
cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf  &>>$LOG_FILE_NAME
validate $? "copying expense conf"
systemctl restart nginx &>>$LOG_FILE_NAME
validate $? "Restart nginx"
