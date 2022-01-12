[ -d /system/xbin ] && BIN=/system/xbin || BIN=/system/bin
if [ -d /sdcard ]; then
  SDCARD=/sdcard
elif [ -d /storage/emulated/0 ]; then
  SDCARD=/storage/emulated/0
fi
if [ ! -d $SDCARD/terminal ]; then
  mkdir -p $SDCARD/terminal
fi
ui_print "   Setting $SDCARD location."
sed -i "s|<SDCARD>|$SDCARD|g; s|<BIN>|$BIN|g" $MODPATH/custom/.bashrc
sed -i "s|<SDCARD>|$SDCARD|g" $MODPATH/system/etc/mkshrc
#sed -i "s|<BIN>|$BIN|g" $MODPATH/custom/.bashrc
if [ ! -f $SDCARD/terminal/.customrc ]; then
  ui_print "   Generating .customrc in $SDCARD/terminal"
  touch $SDCARD/terminal/.customrc
else
  ui_print "   $SDCARD/terminal/.customrc found! Backing up and overwriting!"
  cp -rf $SDCARD/terminal/.customrc $SDCARD/terminal/.customrc.$(date +"%FT%T").bak
  touch $SDCARD/terminal/.customrc
fi
if [ ! -f $SDCARD/terminal/.aliases ]; then
  ui_print "   Copying .aliases to $SDCARD/terminal"
  cp $MODPATH/custom/.aliases $SDCARD/terminal
else
  ui_print "   $SDCARD/terminal/.aliases found! Backing up and overwriting!"
  cp -rf $SDCARD/terminal/.aliases $SDCARD/terminal/.aliases.$(date +"%FT%T").bak
  cp -rf $MODPATH/custom/.aliases $SDCARD/terminal
fi
if [ ! -f $SDCARD/terminal/.bashrc ]; then
  ui_print "   Copying .bashrc to $SDCARD/terminal"
  cp $MODPATH/custom/.bashrc $SDCARD/terminal
else
  ui_print "   $SDCARD/terminal/.bashrc found! Backing up and overwriting!"
  cp -rf $SDCARD/.bashrc $SDCARD/terminal/.bashrc.$(date +"%FT%T").bak
  cp -rf $MODPATH/custom/.bashrc $SDCARD/terminal
fi
