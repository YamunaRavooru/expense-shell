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
echo "Script started executing at :$TIMESTAMP" &>>$LOG_FILE_NAME
check_root 
dnf install mysql-server -y &>>$LOG_FILE_NAME
validate $? "Intalling mysql server"
systemctl enable mysqld  &>>$LOG_FILE_NAME
validate $? "Enabling  mysql"
systemctl start mysqld  &>>$LOG_FILE_NAME
validate $? "starting mysql"
mysql -h mysql.daws82s.cloud -u root -pExpenseApp@1 -e 'show databases;'  &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
  mysql_secure_installation --set-root-pass ExpenseApp@1  &>>$LOG_FILE_NAME
  validate $? "setting root password"
else
  echo -e " mysql Root password is already setup $Y...SKIPPING $N"   
fi  