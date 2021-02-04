#!/bin/sh
#
#
###############################################################################
# r7_show_cpu_mem_usage.sh
# Show Top 3 usage of CPU MEM DISK
###############################################################################


WAS_Team_process="wasadmin"
DB2_Team_process=$(ps -ef| grep db2sys[c] | awk '{print $1}')
MQ_Team_process=$WAS_Team_process' '$DB2_Team_process
linperf_OUTPUT_DIR="/source/linperf"
CPU_threshold="80"
MEM_threshold="80"
. ./mw_hc2.sh


show_menu() {
  clear
  cat << EOF
    ***************** Check USAGE *********************

    1. CPU
    2. MEM
    3. DISK

    q. return to main menu

EOF
}


check_if_var_is_integer(){
  var=$1
  expr $var + 1 >/dev/null 2>&1
  return $?
}


CPU_check() {
  # Displaying top CPU_consuming processes.

  CPU_Highest_owner=$(ps --no-header  -eo user --sort=-%cpu  | head -n 1)
  CPU_Highest_process=$(ps --no-header  -eo cmd --sort=-%cpu  | head -n 1)
  CPU_Highest_usage=$(ps --no-header  -eo %cpu  --sort=-%cpu  | head -n 1)
  CPU_Highest_PID=$(ps --no-header  -eo pid  --sort=-%cpu  | head -n 1)  

  echo ''
  echo ''
  echo "This CPU_Highest_usage user is"
  echo "CPU 使用率最高的使用者是

  \" $CPU_Highest_owner \""
  echo ''
  echo ''
  echo "PID 是 $CPU_Highest_PID"
  echo ''


  if [ ${CPU_Highest_usage%%.*} -gt $CPU_threshold ]; then

    for process in ${MQ_Team_process}; do
      if [[ "${first_process}" == "${process}" ]]; then
        echo ''
        echo "請通知 MQ 組值班人員：以下行程的 CPU 使用率達到  $CPU_Highest_usage%"
        echo $CPU_Highest_process
        echo ''
        echo "PID 是 $CPU_Highest_PID"
        echo ''
        writelog "process: $CPU_Highest_process cpu high $CPU_Highest_usage%, please call MQ Team."
        writelog "PID is $CPU_Highest_PID"
        echo ''
        return 1
      fi
    done

    if [[ "${first_process}" == "${WAS_Team_process}" ]]; then
      # return 1 and linperf
      return 1
    fi

    echo "請通知系統值班人員處理：：以下行程的 CPU 使用率達到 $CPU_Highest_usage%"
    echo " $CPU_Highest_process "
    echo ""
    echo "PID 是 $CPU_Highest_PID"
    echo ""
    echo ""
    writelog "process: $CPU_Highest_process cpu high $CPU_Highest_usage%"
    writelog "PID is  $CPU_Highest_PID"
  fi

  return 0
}


MEM_check() {
  # Displaying top 3 memory-consuming processes.

  MEM_Highest_usage=$(ps --no-header  -eo %mem  --sort=-%mem  | head -n 1)
  first_process=$(ps --no-header  -eo cmd  --sort=-%mem  | head -n 1)
  first_process_pid=$(ps --no-header  -eo pid  --sort=-%mem  | head -n 1)
  echo ''
  echo "This MEM_Highest_usage user is"
  echo "記憶體使用量最高的使用者是 process is 

  \" $first_process \""
  echo ''
  echo ''

  if [ ${MEM_Highest_usage%%.*} -ge 80 ]; then

    for process in ${MQ_Team_process}; do
      if [[ "${first_process}" == "${process}" ]]; then
        echo ''
        echo  "請通知 MQ 組值班人員：$first_process 記憶體使用量達到 $MEM_Highest_usage%"
        writelog "process: $first_process, mem $MEM_Highest_usage%, please call MQ Team."
        echo ''
      fi
    done

    if [[ "${first_process}" == "${WAS_Team_process}" ]]; then
      # return 1 and linperf
      return 1
    fi

    echo "請通知系統值班人員處理：$first_process 記憶體使用量達到 $MEM_Highest_usage%"
    writelog "process: $first_process, mem $MEM_Highest_usage%"
  fi

  return 0
}


DISK_check() {
  # Displaying the process in order of I/O.
  iostat
  return 0
}


exec_linperf_then_scp_log_to_remote_server() {
  pid=$*
  echo 'linperf 預計執行時間需要 5~10 分鐘。'
  echo '請勿多次執行'
  echo ''
  echo '是否要收集(Y/N)？'
  echo 'Do you want Use snap to gather system configuration information?(Y/N)'
  read input
  if ! [[ "${input}" = +([Yy]) ]] ; then
    return 2
  fi

  # remove *.bak, then rename *.tar to *.bak
  if [ "${linperf_OUTPUT_DIR}" == "" ]; then
    writelog "linperf_OUTPUT_DIR variable must be set."
    exit 1
  else
    echo "Clean up ${linperf_OUTPUT_DIR}..."
    for filename in ${linperf_OUTPUT_DIR}/linperf_RESULTS.tar.gz.bak ; do
      rm $filename 2>/dev/null && writelog "刪除 $filename " || writelog "無bak檔可刪除."
    done

    for filename in ${linperf_OUTPUT_DIR}/linperf_RESULTS.tar.gz ; do
      mv "$filename" "${filename}.bak" 2>/dev/null && writelog "將 $filename 更名為 ${filename}.bak "
    done

    for filename in ${linperf_OUTPUT_DIR}/linperf_RESULTS.tar ; do
      rm $filename 2>/dev/null && writelog "刪除 $filename "
    done
    
  fi

  echo "十秒後開始執行 linperf."
  echo "run linperf..."
  sleep 10
  mkdir ${linperf_OUTPUT_DIR}
  chmod 755 ${linperf_OUTPUT_DIR}
  cd ${linperf_OUTPUT_DIR}
  file_prefix=$(hostname)_$(date +%Y%m%d_%H%M%S)_OS
  $HAADMIN_HOME/linperf.sh $pid
  writelog "linperf.sh $pid"
  mv linperf_RESULTS.tar.gz ${file_prefix}_linperf_RESULTS.tar.gz
  if ! [[ $? -eq 0 ]] ; then
    writelog "linperf.sh 未執行 gzip."
    gzip linperf_RESULTS.tar
    mv linperf_RESULTS.tar.gz ${file_prefix}_linperf_RESULTS.tar.gz
  fi

  chmod 744 ${file_prefix}_linperf_RESULTS.tar.gz
  cd $HAADMIN_HOME
  $HAADMIN_HOME/scp_to_file_server.sh ${linperf_OUTPUT_DIR}/${file_prefix}_linperf_RESULTS.tar.gz
  
}


main() {
  while true
  do
    show_menu
    read choice
    case "${choice}" in
      1)
        clear
        CPU_check || exec_linperf_then_scp_log_to_remote_server $CPU_Highest_PID
        echo 'Press enter to continue'
        echo ''
        read null
      ;;
      2)
        clear
        MEM_check || exec_linperf_then_scp_log_to_remote_server $MEM_Highest_PID
        echo 'Press enter to continue'
        echo ''
        read null
      ;;
      3)
        clear
        DISK_check
        echo 'Press enter to continue'
        echo ''
        read null
      ;;
      q)
        clear
        break
      ;;

      *)
        clear
      ;;
    esac
  done
}

main
