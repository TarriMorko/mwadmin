#!/bin/sh
#
#
###############################################################################
# r3_sosreport.sh
# Use sosreport to gather system configuration information.
###############################################################################
# Globals variable :
#   SOS_OUTPUT_DIR              # Identifies the optional sosreport command
#                                # output directory (/var/tmp is the
#                                # default). You must specify the absolute path.
###############################################################################


SOS_OUTPUT_DIR="/source/sosreport"
file_prefix=$(hostname)_$(date +%Y%m%d_%H%M%S)_OS
to_adv_opmenu="0"

. ./mw_hc2.sh
ScriptName="r3_sosreport.sh"


remove_old_sosreport_dir() {
  # remove *.bak, then rename *.tar to *.bak
  if [ "${SOS_OUTPUT_DIR}" == "" ]; then
    writelog "SOS_OUTPUT_DIR variable must be set."
    return 1
  else
    for filename in ${SOS_OUTPUT_DIR}/*_sosreport.tar.gz.bak ; do
      rm $filename 2>/dev/null && writelog "刪除 $filename " || writelog "無bak檔可刪除."
    done
    for filename in ${SOS_OUTPUT_DIR}/*_sosreport.tar.gz ; do
      mv "$filename" "${filename}.bak" 2>/dev/null && writelog "將 $filename 更名為 ${filename}.bak "
    done
  fi
}


execute_sosreport() {
  # sosreport -gbc -d ${SOS_OUTPUT_DIR}
  echo "sosreport 預計執行時間需要 1~10 分鐘。"
  echo "請勿多次執行"
  echo ''
  echo "是否要繼續收集(Y/N)？"
  echo 'Do you want Use sosreport to gather system configuration information?(Y/N)'
  read input
  if [[ "${input}" = +([Yy]) ]] ; then
    remove_old_sosreport_dir
    writelog "sosreport --quiet --batch --compression-type gzip --tmp-dir ${SOS_OUTPUT_DIR}"
    sosreport --quiet --batch --compression-type gzip --tmp-dir ${SOS_OUTPUT_DIR} | tee ${LOGFILENAME}
    rc=$?
    _name=$(tail -n 2 ${LOGFILENAME} | grep sosreport)
    writelog "rename $_name to ${SOS_OUTPUT_DIR}/${file_prefix}_sosreport.tar.gz"
    mv $_name ${SOS_OUTPUT_DIR}/${file_prefix}_sosreport.tar.gz
    chmod -R 775 ${SOS_OUTPUT_DIR}
    chmod 744 ${SOS_OUTPUT_DIR}/${file_prefix}_sosreport.tar.gz
    if [[ $rc -eq 0  ]]; then
      echo ''
      echo ''
      echo "sosreport 收集成功. 檔名是 ${SOS_OUTPUT_DIR}/${file_prefix}_sosreport.tar.gz"
      writelog "sosreport done. filename: ${SOS_OUTPUT_DIR}/${file_prefix}_sosreport.tar.gz"
      echo ''
      echo ''
    else
      echo "sosreport 收集失敗."
      writelog "sosreport fail."
    fi
  else
    return 2
  fi
}


transfer_outputfile_to_logserver() {
  # Use scp to transfer outputfile to a server.
  ${HAADMIN_HOME}/scp_to_file_server.sh ${SOS_OUTPUT_DIR}/${file_prefix}_sosreport.tar.gz
}


clean_up() {
    find ${SOS_OUTPUT_DIR} -name "*.md5" -exec rm {} \;
}


main() {
  execute_sosreport || return $to_adv_opmenu
  transfer_outputfile_to_logserver
  clean_up
}


if [[ "$(basename -- "$0")" == "${ScriptName}" ]]; then
  main
  exit 0
fi
