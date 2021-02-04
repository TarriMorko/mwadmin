#!/bin/bash
#
#

LOGFILENAME="/src/mwadmin/mw_hc2.log"
HAADMIN_HOME="/src/mwadmin"
to_adv_opmenu="0"

# scp_to_file_server.sh, to tsmbk
user=opusr
target=10.0.23.141
target_root_directory="/source/opuse/"
target_directory=${target_root_directory}$(hostname)_$(date +%Y%m%d)

# scp_to_file_server.sh, to tsmP ,for backup
copy_to_tsm_prod="True"  # True / False
user_tsmp=opusr
target_tsmp=10.0.23.133
target_root_directory="/source/opuse/"
target_directory_tsmp=${target_root_directory}$(hostname)_$(date +%Y%m%d)

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

       0. 檢查服務狀態
       1. 顯示機型機號
       2. 新增使用者
       3. 刪除使用者
       4. 變更使用者密碼
       5. 解鎖帳號
       6. 啟動 WAS 服務
       7. 停止 WAS 服務
       8. 啟動ITM監控
       9. 停止ITM監控

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
      0) ./checkwas.sh ;; # su - wasadmin -c "/opt/IBM/WebSphere/usr/servers/gw_server1a_t/bin/server status gw_server1a_t";;
      1) ./showMachineSerial.sh ;;
      2) ./useradd.sh ;;
      3) ./userdel.sh ;;
      4) ./changepassword.sh ;;
      5) ./unlockuser.sh ;;
      6) ./startwas.sh ;; # su - wasadmin -c "/opt/IBM/WebSphere/usr/servers/gw_server1a_t/bin/server start gw_server1a_t" ;;
      7) ./stopwas.sh ;;  #su - wasadmin -c "/opt/IBM/WebSphere/usr/servers/gw_server1a_t/bin/server stop gw_server1a_t" ;;
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

if [[ "$(basename -- "$0")" == "${ScriptName}" ]]; then
  if [ ! -e "${LOGFILENAME}" ] ; then
    touch ${LOGFILENAME}
  fi
  if [ ! -e "${ERRFILENAME}" ] ; then
    touch ${ERRFILENAME}
  fi
  chown root ${LOGFILENAME}
  chmod 540 ${LOGFILENAME}
  chown root ${ERRFILENAME}
  chmod 540 ${ERRFILENAME}
  main
  exit 0
fi