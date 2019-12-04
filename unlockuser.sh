#!/bin/bash
#
#
# 請輸入 Username
# 請輸入 User's Full Name
# 請輸入 Password
# 請再輸入一次 Password
# 請輸入 UID
# 請輸入 GID

LOGFILENAME="/src/mwadmin/mw_hc2.log"

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

get_username() {
    echo "解鎖使用者"
    echo ""
    echo "請輸入 Username，按 ENTER 離開。"
    read username
    id "${username}" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        return 0
    elif [[ "${username}" == '' ]]; then
        echo "返回前一頁。"
        return 1
    else
        echo "請輸入正確的 username"
        return 1
    fi
}

exec_useradd() {
    echo "即將執行命令： /sbin/pam_tally2 --reset -u $username"
    writelog "Command:  /sbin/pam_tally2 --reset -u $username"
    /sbin/pam_tally2 --reset -u $username 2>>${LOGFILENAME}
    if [[ $? -eq 0 ]]; then
        id $userID
        writelog "解鎖使用者 $username 成功。"
    else
        writelog "解鎖使用者 $username 失敗。"
        echo "請檢視 ${LOGFILENAME}"
    fi
    return 0
}

main() {
    clear
    get_username || return $to_adv_opmenu

    exec_useradd

}
main
