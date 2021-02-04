#!/bin/bash
#
#

LOGFILENAME="/src/mwadmin/mw_hc2.log"
HAADMIN_HOME="/src/mwadmin"
to_adv_opmenu="0"
ScriptName="mw_hc2.sh"

# scp_to_file_server.sh, to tsmbk
user=opusr
target=10.0.31.206
# target=192.168.137.113
target_root_directory="/source/opuse/"
target_directory=${target_root_directory}$(hostname)_$(date +%Y%m%d)

# scp_to_file_server.sh, to tsmP ,for backup
copy_to_tsm_prod="False"  # True / False
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

       R1. 
       R2. 
       R3. sosreport (collect system info)
       R4. linperf   (collect profess info, when CPU high.)
       R5. 
       R6. Check FileSystem Size
       R7. Check CPU Memory DISK usages
       R8. cat system file

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
      [Rr]3) ./r3_sosreport.sh ;;
      [Rr]4) ./r4_linperf.sh ;;
      [Rr]6) ./r6_check_FS_size.sh ;;
      [Rr]7) ./r7_show_cpu_mem_usage.sh ;;
      [Rr]8) ./r8_copy_to_file_server.sh ;;

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