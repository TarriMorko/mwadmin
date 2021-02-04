#!/bin/sh
#
#
###############################################################################
# r8_copy_to_file_server.sh
# cat file setting
###############################################################################
# Globals variable :
#   CAT_OUTPUT_DIR
#   HAADMIN_HOME
###############################################################################


CAT_OUTPUT_DIR="/source/system_out"
HAADMIN_HOME="${HAADMIN_HOME}"
to_adv_opmenu="0"

. ./mw_hc2.sh
ScriptName="r8_copy_to_file_server.sh"
readonly outputfile=$(hostname)_$(date +"%Y%m%d_%H%M%S")_r8.txt


check_filename_usability() {
  input_filename=$1
  if ! [[ "${input_filename}" = *@(/)*([0-9a-zA-Z._/]) ]] ; then
    echo '請輸入正確檔名。'
    echo 'filename error.'
    return 1
  fi

  if [ -d ${input_filename} ] ; then
    echo '不能輸入一個目錄。'
    echo 'Can not input a directory.'
    return 3
  fi

  if ! [ -r ${input_filename} ] ; then
    echo '找不到檔案或無法讀取。'
    echo 'File not found or can not read file.'
    return 4
  fi

  filesize=$(du -m $input_filename | cut -f1)
  if [ "${filesize}" -gt 10 ]; then
    echo '檔案超過 10 MB。'
    echo 'file too large'
    return 5
  fi
}


echo_file_contain_and_store_in_outputdir() {
  mkdir -p ${CAT_OUTPUT_DIR}
  chmod 755 ${CAT_OUTPUT_DIR}
  echo "${input_filename}" > ${CAT_OUTPUT_DIR}/$outputfile
  cat "${input_filename}" | tee -a ${CAT_OUTPUT_DIR}/$outputfile
  chmod 774 ${CAT_OUTPUT_DIR}/$outputfile
}


transfer_outputfile_to_logserver() {
  $HAADMIN_HOME/scp_to_file_server.sh ${CAT_OUTPUT_DIR}/$outputfile
}


main() {
  clear
  find ${CAT_OUTPUT_DIR} -name "*_r8.txt" -exec rm {} \;
  echo "請輸入想要傳送的檔案名稱:"
  echo 'Please enter which file you want to transer:'
  read input
  check_filename_usability $input || return $to_adv_opmenu
  echo_file_contain_and_store_in_outputdir
  transfer_outputfile_to_logserver
}


if [[ "$(basename -- "$0")" == "${ScriptName}" ]]; then
  main
  exit 0
fi
