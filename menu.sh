#!/bin/bash
#
#

LOGFILENAME="/src/mwadmin/mw_hc2.log"
HAADMIN_HOME="/src/mwadmin"
to_adv_opmenu="0"

writelog() {
    #######################################
    # Writing log to specify file
    # Globals:
    #    LOGFILENAME
    # Arguments:
    #    _caller
    #    log_message
    # Returns:
    #    None
    # Example:
    #    write_log "Hello World!"
    # then a message "2014-11-22 15:38:54 [who_call] Hello World!"
    # writing in file LOGFILENAME.
    #######################################
    #_caller=$(echo $0 | cut -d'/' -f2)
    _caller=$(echo ${0##*/} | awk '{print substr($0,1,24)}')
    log_message=$@
    echo "$(date +"%Y-%m-%d %H:%M:%S") [$_caller] ${log_message}" | tee -a ${LOGFILENAME}
}

show_main_menu() {
  clear
  cat << EOF
  +====================================================================+
       Hostname: $(hostname)
       Today is $(date +%Y-%m-%d)
  +====================================================================+

       1. 新增使用者
       2. 刪除使用者
       3. 變更使用者密碼
       4. 解鎖帳號

        ......
        q.QUIT

        Enter your choice (0-16, q) :

EOF
}


main() {
# The entry for sub functions.
  while true
  do
    cd ${HAADMIN_HOME}
    show_main_menu
    read choice
    clear
      case $choice in
      1) ${HAADMIN_HOME}/useradd.sh ;;
      2) ${HAADMIN_HOME}/userdel.sh ;;
      3) ${HAADMIN_HOME}/changepassword.sh ;;
      4) ${HAADMIN_HOME}/unlockuser.sh ;;
      q)
        echo ''
        echo 'Thanks !! bye bye ^-^ !!!'
        echo ''
        #logout
        exit;logout
        ;;      
      *)
        clear;clear
        echo ''
        echo 'PRESS ENTER TO CONTINUE ... !!!'
        read choice
        ;;
      esac
      echo ''
      echo 'Press enter to continue' && read null
  done
}

main
