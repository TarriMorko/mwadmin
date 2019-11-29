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
    echo "建立新使用者"
    echo ""
    echo "請輸入 Username，按 ENTER 離開。"
    read username
    echo "${username}" | egrep '^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$' >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        return 0
    elif [[ "${username}" == '' ]]; then
        echo "返回前一頁。"
        return 1
    else
        echo "請輸入可用的 username"
        return 1
    fi
}

get_userfullname() {
    echo "請輸入 User's Full Name 或註解。"
    read userfullname
    return 0
}

get_userpassword() {
    echo "請輸入 password。"
    read -s userpassword
    return 0
}

get_userhome() {
    # 懶得改
    echo "none"
}

get_UID() {
    echo "請輸入 UID"
    read userID
    echo "${userID}" | egrep '^[0-9]{0,5}$' >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        return 0
    elif [[ "${userID}" == '' ]]; then
        echo "返回前一頁。"
        return 1
    else
        echo "請輸入可用的 UID"
        return 1
    fi
}

get_GID() {
    echo "請輸入 GID"
    read userGID
    cat /etc/group | awk -F':' '{print $3}' | grep --word-regexp "${userGID}" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        return 0
    elif [[ "${userGID}" == '' ]]; then
        echo "返回前一頁。"
        return 1
    else
        echo "請輸入可用的 GID"
        return 1
    fi
}

exec_useradd() {
    echo "即將執行命令： useradd --uid $userID --gid $userGID --comment \"${userfullname}\" $username"
    read -r -p "確認建立使用者? [y/N] " response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
        writelog "Command: useradd --uid $userID --gid $userGID --comment "${userfullname}" $username"
        useradd --uid $userID --gid $userGID --password "${password}" --comment "${userfullname}" $username 2>>${LOGFILENAME}
        if [[ $? -eq 0 ]]; then
            id $userID
            writelog "建立使用者 $username 成功。"
        else
            writelog "建立使用者 $username 失敗。"
            echo "請檢視 ${LOGFILENAME}"
        fi
        return 0
    else
        echo "取消，回到上一頁。"
        return 1
    fi
}

main() {
    clear
    get_username || return $to_adv_opmenu
    get_userfullname || return $to_adv_opmenu
    get_UID || return $to_adv_opmenu
    get_GID || return $to_adv_opmenu

    exec_useradd

}
main
