#!/bin/bash
#
#

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
    echo "變更使用者密碼"
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

exec_changepassword() {
    writelog "Command: passwd $username"
    passwd $username
    if [[ $? -eq 0 ]]; then
        writelog "變更使用者密碼 $username 成功。"
    else
        writelog "變更使用者密碼 $username 失敗。"
    fi
}

main() {
    clear
    get_username || return $to_adv_opmenu
    exec_changepassword
}
main
