#!/bin/sh
#
#
###############################################################################
# scp_to_file_server.sh
# for file transfer
###############################################################################
# example:
#
#  ./scp_to_file_server.sh FILE
#
#  then the FILE will copy to remote server

# scp_to_file_server.sh, to tsmbk
user=opusr
target=10.0.31.206
target_root_directory="/source/opuse/"
target_directory=${target_root_directory}$(hostname)_$(date +%Y%m%d)

# scp_to_file_server.sh, to tsmP ,for backup
copy_to_tsm_prod="False"  # True / False
user_tsmp=opusr
target_tsmp=10.0.23.133
target_root_directory="/source/opuse/"
target_directory_tsmp=${target_root_directory}$(hostname)_$(date +%Y%m%d)

. ./mw_hc2.sh

full_filename=$1
filename=${full_filename##*/}
ScriptName="scp_to_file_server.sh" # Overrige ScriptName in mw_hc2.sh
to_adv_opmenu="0"


check_log_server_ssh_connection() {
  # Check remote server connection
  writelog "Connecting to $target... "
  su opusr -c "ssh $user@$target hostname 2>/dev/null 1>/dev/null"
  rc=$?
  if [ $rc == "0" ]; then
    echo 'ssh 成功連線至' "$target."
    writelog "ssh connect to $target success."
    echo ''
    return 0
  else
    echo '連線至' "$target" '失敗'
    writelog "ssh connect to $target fail."
    echo ''
    return 1
  fi
}


make_remote_directory_and_transfer_file_to_log_server() {
  echo ''
  echo ''
  echo ''
  su opusr -c "ssh $user@$target mkdir -p $target_directory"  || writelog "在 $target 建立 $target_directory 失敗"
  su opusr -c "ssh $user@$target chmod 755 $target_directory"
  echo '準備傳送檔案, 請稍後...'
  writelog "prepare to transfer file..."
  echo ''

  su opusr -c "scp $full_filename $user@$target:$target_directory"
  #su opusr -c "scp $full_filename $user@$target:$target_directory"
  if [[ $? -eq 0  ]]; then
    writelog "File transfer success, please download at host $target : $target_directory/$filename"
    su opusr -c "ssh $user@$target chmod 744 $target_directory/$filename"
    echo ''
    echo "檔案傳送成功, 請在 $target 主機下載 $target_directory/$filename"
    echo ''
    echo '- - - - - - - - - - - - - - - - - - - - - - -'
    echo '請接續下載步驟：'
    echo '- - - - - - - - - - - - - - - - - - - - - - -'
    echo '請開啟 filezilla'
    echo '主機'"： sftp://${target}"
    echo '使用者名稱：opusr'
    echo '密碼： <查表>'
    echo '連接埠：22'
    echo '按快速連線'
    echo '遠端站台：' "$target_directory"
    echo '按Enter'
    echo '檔案名稱：' "$filename"
    echo '點選此檔拉到左邊選單，即下載完成。'
    return 0
  else
    echo "檔案傳送到 $target 失敗."
    writelog "File tranfer to $target fail."
    return 1
  fi

  su opusr -c "ssh $user@$target chmod 755 $target_directory/$filename"
  su opusr -c "ssh $user@$target chmod 755 $target_directory"
  su opusr -c "ssh $user@$target chmod 755 ${target_root_directory}"
}


slient_copy_to_tsm_prod() {
  # ugly
  # user_tsmp=opusr
  # target_tsmp=fxdb2t
  target_directory_tsmp=${target_root_directory}$(hostname)_$(date +%Y%m%d)
  su opusr -c "ssh $user_tsmp@$target_tsmp mkdir -p $target_directory_tsmp"
  su opusr -c "ssh $user_tsmp@$target_tsmp chmod 755 $target_directory_tsmp"
  su opusr -c "scp $full_filename $user_tsmp@$target_tsmp:$target_directory_tsmp" && writelog "copy to $target_tsmp success."
  su opusr -c "ssh $user_tsmp@$target_tsmp chmod 755 $target_directory_tsmp/$filename"
  su opusr -c "ssh $user_tsmp@$target_tsmp chmod 755 $target_directory_tsmp"
  su opusr -c "ssh $user_tsmp@$target_tsmp chmod 755 ${target_root_directory}"
}


main() {
  check_log_server_ssh_connection || exit 1
  make_remote_directory_and_transfer_file_to_log_server
  if [ $copy_to_tsm_prod = "True" ]; then
    slient_copy_to_tsm_prod
  fi
}


if [[ "$(basename -- "$0")" == "${ScriptName}" ]]; then
  main
  exit 0
fi
