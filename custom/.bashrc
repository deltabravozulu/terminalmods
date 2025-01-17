export host=android
export HOME=/
export HOSTNAME=$(getprop ro.product.device)
export TERM=xterm
export TMPDIR=/data/local/tmp
export USER=$(id -un)
#export BBDIR="/sbin/.magisk/busybox"
export BBDIR="/data/adb/magisk"
export PATH=${PATH}:/sbin:${BBDIR}:.


# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

# Expand the history size
HISTFILESIZE=10000
HISTSIZE=100
# ... and ignore same sucessive entries.
HISTCONTROL=ignoreboth

rootcheck() {
  ROOT= && [ $USER = root ] || ROOT="su -c"
}
createaliases() {
  echo -e "# .gnualiases\n" >/sdcard/terminal/.gnualiases
  find /data/adb/modules/gnu/system/bin -type l -or -type f >>/sdcard/terminal/.gnualiases
  find /data/adb/modules/gnu/system/xbin -type l -or -type f >>/sdcard/terminal/.gnualiases
  sed -i "s|/data/adb/modules/gnu/system/bin/|alias |" /sdcard/terminal/.gnualiases
  sed -i "s|/data/adb/modules/gnu/system/xbin/|alias |" /sdcard/terminal/.gnualiases
  sed -ri "s|alias (.*)|alias \1=\'/system/xbin/\1\'|" /sdcard/terminal/.gnualiases
  sed -i "s|cp'|cp -g'|" /sdcard/terminal/.gnualiases
  sed -i "s|mv'|mv -g'|" /sdcard/terminal/.gnualiases
  sed -i "s|#wew\[|\[|" /sdcard/terminal/.bashrc
  . /sdcard/terminal/.gnualiases
}
cdn() {
  cmd=""
  for ((i = 0; i < $1; i++)); do
    cmd="$cmd../"
  done
  cd "$cmd"
}
setpriority() {
  rootcheck
  case $2 in
  high)
    $ROOT cmd overlay set-priority $1 lowest
    $ROOT cmd overlay set-priority $1 highest
    ;;
  low)
    $ROOT cmd overlay set-priority $1 highest
    $ROOT cmd overlay set-priority $1 lowest
    ;;
  *)
    echo "Usage: setpriority overlay [option]"
    echo " "
    echo "Options:"
    echo " high - Sets the overlay to the highest priority"
    echo " low  - Sets the overlay to the lowest priority"
    ;;
  esac
}
adbfi() {
  rootcheck
  case $1 in
  on)
    $ROOT setprop service.adb.tcp.port 5555
    $ROOT stop adbd
    $ROOT start adbd
    echo "ADB over WiFi enabled"
    ;;
  off)
    $ROOT setprop service.adb.tcp.port -1
    $ROOT stop adbd
    $ROOT start adbd
    echo "ADB over WiFi disabled"
    ;;
  stats) case $(getprop service.adb.tcp.port) in -1) echo "off" ;; 5555) echo "on" ;; *) echo "off" ;; esac ;;
  *)
    echo "Usage: adbfi [option]"
    echo " "
    echo "Options:"
    echo " on    - Enables ADB over Wifi"
    echo " off   - Disables ADB over WiFi"
    echo " stats - Gets current status"
    ;;
  esac
}
overlays() {
  opt=$1
  rootcheck
  [ "$2" ] || opt=null
  case $opt in
  enable)
    shift
    for i in $($ROOT cmd overlay list | grep -iE "^\[.*$1" | sed 's|\[.* ||g'); do $ROOT cmd overlay enable $i; done
    ;;
  disable)
    shift
    for i in $($ROOT cmd overlay list | grep -iE "^\[.*$1" | sed 's|\[.* ||g'); do $ROOT cmd overlay disable $i; done
    ;;
  list)
    shift
    overlayList=$($ROOT cmd overlay list | grep -iE "^\[.*$1")
    echo "$overlayList"
    ;;
  *)
    echo "Usage: overlays [option] (keyword)"
    echo " "
    echo "Options:"
    echo " enable  - Enables all overlays that include the keyword in the packagename"
    echo " disable - Disables all overlays that include the keyword in the packagename"
    echo " list    - Lists all overlays that include the keyword in the packagename"
    ;;
  esac
}

# establish colours for PS1
green="\e[1;32m\]"
cyan="\e[1;36m\]"
purple="\e[1;35m\]"
blank="\e[m\]"

# Sexy af PS1
export PS1="${green}┌|\@${cyan} ${HOSTNAME} at ${host}${purple} in \W \n${green}└─${blank} \$ "

# Source aliases and stuff
. /sdcard/terminal/.aliases
#wew[ -d /data/adb/modules/gnu ] && . /sdcard/terminal/.gnualiases
. /sdcard/terminal/.customrc

####################################ALL NEW#####################
###Termux related integrations
export TERMUX="/data/data/com.termux/files"
export TBIN="$TERMUX/usr/bin"
#PATH add home bin
export PATH=$TERMUX/home/bin:$PATH
export PATH=$TERMUX/usr/bin:$PATH



if [ -f /data/data/com.termux/files/home/bin/cdb ]; then
    source /data/data/com.termux/files/home/bin/cdb
fi

#Custom shell prompt ip getter
ip_wlan=$($TBIN/ifconfig 2>/dev/null | grep -v inet6 | grep ^wlan -A3 | grep 'inet' | awk '{print $2}')
ip_mobile=$($TBIN/ifconfig 2>/dev/null | grep -v inet6 | grep ^rmnet -A3 | grep 'inet' | awk '{print $2}')
ip_local=$($TBIN/ifconfig 2>/dev/null | grep -v inet6 | grep ^lo -A3 | grep 'inet' | awk '{print $2}')

function ip_setter() {
  if [[ -n ${ip_wlan:+x} ]] && [[ -n ${ip_mobile:+x} ]]; then
    IP="$ip_wlan(w)|@$ip_mobile(m)"
  elif [[ -n ${ip_wlan:+x} ]]; then
    IP="$ip_wlan(w)"
  elif [[ -n ${ip_mobile:+x} ]]; then
    IP="$ip_mobile(m)"
  else
    IP="$ip_local(l)"
  fi
  echo $IP
}

#Set custom shell prompt
export PS1='\[\033[00;33m\]\u\
\[\033[00;34m\]@$(ip_setter):\
\[\033[38;5;9m\]$(pwd)\
\[\033[00;40m\]\$\
\[\033[00;32m\] '
