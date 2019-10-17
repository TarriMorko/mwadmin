#!/bin/bash
#
#
# 請輸入 Username
# 請輸入 User's Full Name
# 請輸入 Password
# 請再輸入一次 Password
# 請輸入 Login Shell (按 enter 使用預設值)
# 請輸入使用者家目錄 (按 enter 使用預設值)
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
    username=$(whiptail --title "建立新使用者" --inputbox "請輸入 Username" 10 60 3>&1 1>&2 2>&3)
    echo "${username}" | egrep '^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$' >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        return 0
    elif [[ "${username}" == '' ]]; then
        whiptail --title "建立新使用者" --msgbox "返回前一頁。" 10 60
        return 1
    else
        whiptail --title "建立新使用者" --msgbox "請輸入可用的 username" 10 60
        return 1
    fi
}

get_userfullname() {
    userfullname=$(whiptail --title "建立新使用者" --inputbox "請輸入 User's Full Name" 10 60 3>&1 1>&2 2>&3)
    return 0
}

get_userpassword() {
    userpassword=$(whiptail --title "建立新使用者" --passwordbox "請輸入 password" 10 60 3>&1 1>&2 2>&3)
    return 0
}

get_loginshell() {
    loginshell=$(whiptail --title "建立新使用者" --inputbox "請輸入 login shell，按 enter 使用預設值 /bin/bash" 10 60 "/bin/bash" 3>&1 1>&2 2>&3)
    cat /etc/shells | grep --word-regexp "${loginshell}" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        return 0
    else
        whiptail --title "建立新使用者" --msgbox "請輸入可用的 shell" 10 60
        return 1
    fi
    return 0
}

get_userhome() {
    # 懶得改
    echo "none"
}

get_UID() {
    userID=$(whiptail --title "建立新使用者" --inputbox "請輸入 UID" 10 60 3>&1 1>&2 2>&3)
    echo "${userID}" | egrep '^[0-9]{0,5}$' >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        return 0
    elif [[ "${userID}" == '' ]]; then
        whiptail --title "建立新使用者" --msgbox "返回前一頁。" 10 60
        return 1
    else
        whiptail --title "建立新使用者" --msgbox "請輸入可用的 UID" 10 60
        return 1
    fi
}

get_GID() {
    userGID=$(whiptail --title "建立新使用者" --inputbox "請輸入 GID" 10 60 3>&1 1>&2 2>&3)
    cat /etc/group | awk -F':' '{print $3}' | grep --word-regexp "${userGID}" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        return 0
    elif [[ "${userGID}" == '' ]]; then
        whiptail --title "建立新使用者" --msgbox "返回前一頁。" 10 60
        return 1
    else
        whiptail --title "建立新使用者" --msgbox "請輸入可用的 GID" 10 60
        return 1
    fi
}

exec_useradd() {
    whiptail --title "建立新使用者" --yesno "即將執行\n useradd --uid $userID --gid $userGID --comment ${userfullname} --shell ${loginshell} $username" 10 80
    if [[ $? -eq 0 ]]; then
        writelog "Command: useradd --uid $userID --gid $userGID --comment "${userfullname}" --shell ${loginshell} $username"
        useradd --uid $userID --gid $userGID --comment "${userfullname}" --shell ${loginshell} $username 2>>${LOGFILENAME}
        if [[ $? -eq 0 ]]; then
            id $userID
            writelog "建立使用者 $username 成功。"
        else
            writelog "建立使用者 $username 失敗。"
        fi
        return 0
    else
        whiptail --title "建立新使用者" --msgbox "取消" 10 60
        return 1
    fi
}

main() {
    get_username || return $to_adv_opmenu
    get_userfullname || return $to_adv_opmenu
    get_loginshell || return $to_adv_opmenu
    get_UID || return $to_adv_opmenu
    get_GID || return $to_adv_opmenu

    exec_useradd

}
main
