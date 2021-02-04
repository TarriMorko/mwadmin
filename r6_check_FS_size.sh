#!/bin/sh
#
#
###############################################################################
# r6_check_FS_size.sh
# check FileSystem size
###############################################################################
# Globals variable :
#   defualt_FileSystem
#   SizeLowerLimit                    # size present by df
###############################################################################


defualt_FileSystem="/source"
SizeLowerLimit="2000"

. ./mw_hc2.sh  # commet This line if you want to use local setting

echo ""
echo "請輸入想要判斷大小的檔案系統，或者按 Enter 使用預設值 ${defualt_FileSystem}"
echo "Please Enter which FileSystem you want to check:"
echo "current setting is ${defualt_FileSystem}, press ENTER to use default setting."
echo ""

read fileSystem
if [[ -z "${fileSystem}" ]]; then
  fileSystem="${defualt_FileSystem}"
fi

df -m "${fileSystem}" 2>/dev/null 1>/dev/null
return_code=$?
if [ $return_code -ne 0 ]; then
  echo "錯誤, 無法檢查 ${fileSystem}."
  echo "Error, Can not check ${fileSystem}."
  exit 1
fi

fileSystemSizeRemain=$(df -m "${fileSystem}" | tail -n 1 | awk '{print $3}')

if [ ${fileSystemSizeRemain} -gt ${SizeLowerLimit} ]; then
  echo  "${fileSystem} 空間足夠，剩餘 $fileSystemSizeRemain MB"
  writelog "$(hostname) ${fileSystem} enough, $fileSystemSizeRemain MB left."
else
  echo  "${fileSystem} 空間不足，剩餘 $fileSystemSizeRemain MB"
  writelog "$(hostname) ${fileSystem} not enough, $fileSystemSizeRemain MB left."
fi
