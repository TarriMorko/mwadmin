#!/bin/sh
#
#
###############################################################################
# r4_linperf.sh
# execute linperf.sh
###############################################################################

linperf_OUTPUT_DIR="/source/linperf"
. ./mw_hc2.sh
ScriptName="r4_linperf.sh"
to_adv_opmenu="0"


ask_pid_for_linperf() {
  clear
  echo '請輸入 pid(s) 以供 linperf 執行.'
  read pid
}


check_pid() {
  # 檢查輸入的所有參數是否為數字, 有一個不合法就返回 1
  # 都為數字就返回 $pids
    unchecked_pids=$*
  if [[ "${unchecked_pids}" == "" ]] ; then
    echo '請輸入正確 pid.'
    echo ''
    echo '請按任意鍵繼續' && read null
    exit 1
  fi

  for unchecked_pid in $unchecked_pids; do
    if ! [[ "${unchecked_pid}" = *([0-9]) ]] ; then
      echo 'pid 輸入錯誤，請輸入正確 pid.'
      echo ''
      echo '請按任意鍵繼續' && read null
      exit 1
    fi

    check_if_pid_exist=$(ps -ef | grep $unchecked_pid | grep -v grep)
    if [ "${check_if_pid_exist}" == "" ]; then
      echo 'pid 不存在，請輸入正確 pid.'
      echo ''
      echo '請按任意鍵繼續' && read null
      exit 1
    fi

    if [ "${unchecked_pid}" == "1" ]; then
      echo '不可輸入 pid 為 1.'
      echo ''
      echo '請按任意鍵繼續' && read null
      exit 1
    fi

    if [ "${unchecked_pid}" == "0" ]; then
      echo '不可輸入 pid 為 0.'
      echo ''
      echo '請按任意鍵繼續' && read null
      exit 1
    fi

  done

  pids=$unchecked_pids
  return 0
}


exec_linperf() {
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
    for filename in ${linperf_OUTPUT_DIR}/*_linperf_RESULTS.tar.gz.bak ; do
      rm $filename 2>/dev/null && writelog "刪除 $filename " || writelog "無bak檔可刪除."
    done

    for filename in ${linperf_OUTPUT_DIR}/*_linperf_RESULTS.tar.gz ; do
      mv "$filename" "${filename}.bak" 2>/dev/null && writelog "將 $filename 更名為 ${filename}.bak "
    done

    for filename in ${linperf_OUTPUT_DIR}/*_linperf_RESULTS.tar ; do
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
  return 0
}


transfer_files() {
  $HAADMIN_HOME/scp_to_file_server.sh ${linperf_OUTPUT_DIR}/${file_prefix}_linperf_RESULTS.tar.gz
}


main() {
  ask_pid_for_linperf
  check_pid $pid || return $to_adv_opmenu
  exec_linperf $pid || return $to_adv_opmenu
  transfer_files
}


if [[ "$(basename -- "$0")" == "${ScriptName}" ]]; then
  main
  exit 0
fi
