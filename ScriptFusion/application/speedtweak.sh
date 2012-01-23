#!/system/bin/sh

# Copyright (C) 2011 Twisted Playground

# ScriptFusion - Twisted Playground System Toolkit
# AutoBot Android Market Application Modification
# http://code.google.com/p/cupcake-frosting/
#
# ScriptFusion is built and updated by TwistedUmbrella
# All code and releases completed on the HTC Thunderbolt
# Original speedtweak voltage profiles credit imoseyon
# 6.2.1 Tweak Package and concept credit imoseyon
# Scheduler editing concept credit nerozehl
# 3G / Memory research credit zeppelinrox
# Original Adblock function credit yareally
# Volume wake concept credit DroidTh3ory
# Fusion name transition credit sublimaze
# Dangerous code testing credit gokudre
#
# Please include credits with any use of included code
#
# User-based code for blocking specific forum members
# autoban() {
# banuser=`busybox grep -m 1 -iF $username /data/data/com.quoord.*.activity/shared_prefs/com.quoord.*.activity.ForumNavigationActivity.xml`
# if [ $banuser ]; then
# Fill in specific function, process or item to prevent use of
# One example is triggering "reboot recovery" in a boot script
# fi } - called by running autoban with a declared username

# Prerequisite Functions

server="http://twistedumbrella.github.com"
busyfusion="/data/data/com.fusion.tbolt/files/busybox"
wgetfusion="/data/data/com.fusion.tbolt/files/wget"
alignfusion="/data/data/com.fusion.tbolt/files/zipalign"
rebootfusion="/data/data/com.fusion.tbolt/files/reboot"
flashfusion="/data/data/com.fusion.tbolt/files/flash_image"
wgetcheck=`$busyfusion stat -c %s /system/xbin/wget`
busycheck=`$busyfusion | busybox head -n 1 | busybox awk '{ print $2 }'`
checkinitial=`$busyfusion grep -q -m 1 -F 'run-parts /system/etc/init.d' /init.rc`
checkaosp=`$busyfusion grep -q -m 1 -F 'exec /system/bin/sysinit' /init.rc`
viewitem="am start -a android.intent.action.MAIN -n com.fusion.tbolt/.AccessZero -e address"
customsys=`$busyfusion grep -q -m 1 -F "#\ Customized" /system/etc/sysctl.conf`
minfreq=`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq`
maxfreq=`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq`
ifile="/system/etc/init.d/01vdd_levels"
sfile="/system/etc/init.d/02sched_choice"
ofile="/system/etc/init.d/00twist_override"
tfile="/system/etc/init.d/99imotwist_tweaks"
vfile="/system/etc/init.d/03vibrate_config"

wetinitialize() {

cd /
echo
echo "HiJacking Console Sanity..."
$busyfusion mount -o remount,rw -t yaffs2 `$busyfusion grep /system /proc/mounts | $busyfusion cut -d' ' -f1` /system
$busyfusion mount -o rw,remount /system
$busyfusion mount -o rw,remount /
availablemounts=`$busyfusion ls -x /dev/block/vold | $busyfusion awk '{ print $1 }'`
if [ $availablemounts ]
then
$busyfusion mount -o remount,exec /dev/block/vold/$availablemounts /sdcard
fi
sleep 1

}

dryinitialize() {

$busyfusion mount -o remount,rw -t yaffs2 `$busyfusion grep /system /proc/mounts | $busyfusion cut -d' ' -f1` /system
$busyfusion mount -o rw,remount /system
$busyfusion mount -o rw,remount /
cd /
if [ -e /sbin/speedtweak.sh ]; then
$busyfusion rm -rf /sbin/speedtweak.sh
fi
ln -s /data/data/com.fusion.tbolt/files/speedtweak.sh /sbin/speedtweak.sh

}

line=================================================

# Configuration Files

generatevoltages() {

echo '#!/system/bin/sh' > $ifile
echo '# Mode: safe' >> $ifile
echo "echo $minfreq > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq" >> $ifile
n=1
while [ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $'$n' }'` ]
do
n=`$busyfusion expr $n + 1`
done
safehalf=`$busyfusion expr $n / 2`
safemax=`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $'$safehalf' }'`
echo "echo $safemax > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq" >> $ifile

chmod 555 $ifile

}

generateschedule() {

echo '#!/system/bin/sh' > $sfile
echo 'echo deadline > /sys/block/mmcblk0/queue/scheduler' >> $sfile

chmod 555 $sfile

}

generatesysctl() {

if [ ! -e /system/init.d/98kickasskernel ]
then

echo '# Customized Sysctl' > /system/etc/sysctl.conf
if [ -e /proc/sys/vm/vfs_cache_pressure ]; then
echo 'vm.vfs_cache_pressure = 5' >> /system/etc/sysctl.conf
fi
if [ -e /proc/sys/vm/dirty_expire_centisecs ]; then
echo 'vm.dirty_expire_centisecs = 500' >> /system/etc/sysctl.conf
fi
if [ -e /proc/sys/vm/dirty_writeback_centisecs ]; then
echo 'vm.dirty_writeback_centisecs = 1000' >> /system/etc/sysctl.conf
fi
if [ -e /proc/sys/vm/dirty_ratio ]; then
echo 'vm.dirty_ratio = 90' >> /system/etc/sysctl.conf
fi
if [ -e /proc/sys/vm/dirty_background_ratio ]; then
echo 'vm.dirty_background_ratio = 70' >> /system/etc/sysctl.conf
fi
if [ -e /proc/sys/vm/oom_kill_allocating_task ]; then
echo 'vm.oom_kill_allocating_task = 1' >> /system/etc/sysctl.conf
fi
if [ -e /proc/sys/vm/min_free_kbytes ]; then
echo 'vm.min_free_kbytes = 4096' >> /system/etc/sysctl.conf
fi

chmod 755 /system/etc/sysctl.conf

else
if [ -e /system/etc/sysctl.conf ]
then
$busyfusion rm -rf /system/etc/sysctl.conf
fi
fi

}

generateoverride() {

echo '#!/system/bin/sh' > $ofile
echo 'busyfusion="/data/data/com.fusion.tbolt/files/busybox"' >> $ofile
echo '$busyfusion mount -o remount,rw -t yaffs2 `$busyfusion grep /system /proc/mounts | $busyfusion cut -d" " -f1` /system' >> $ofile
echo '$busyfusion mount -o rw,remount /system' >> $ofile
echo '$busyfusion mount -o rw,remount /' >> $ofile
echo 'cd /' >> $ofile
echo 'if [ -e /sbin/speedtweak.sh ]; then' >> $ofile
echo '$busyfusion rm -rf /sbin/speedtweak.sh' >> $ofile
echo 'fi' >> $ofile
echo 'ln -s /data/data/com.fusion.tbolt/files/speedtweak.sh /sbin/speedtweak.sh' >> $ofile
echo '$busyfusion mount -o ro,remount /' >> $ofile
echo '$busyfusion mount -o ro,remount /system' >> $ofile
echo '$busyfusion mount -o remount,ro -t yaffs2 `$busyfusion grep /system /proc/mounts | $busyfusion cut -d" " -f1` /system' >> $ofile

chmod 555 $ofile

if [ $checkinitial ] && [ $checkaosp ]
then
IR="/system/etc/install-recovery.sh"
if [ ! -f $IR ]; then
echo "#!/system/bin/sh" > $IR
else
$busyfusion sed -i /run-parts/d $IR
# B=`$busyfusion egrep -c 'run-parts' $IR`
# [ $B -gt 0 ] && exit
fi
echo "$busyfusion run-parts /system/etc/init.d" >> $IR
chmod 755 $IR
fi

}

buildproperties() {

$busyfusion cp /system/build.prop /system/build.prop.sfb
$busyfusion sed -i 's/dalvik.vm.heapsize.*=.*m/dalvik.vm.heapsize=48m/g' /system/build.prop
$busyfusion sed -i 's/windowsmgr.max_events_per_sec.*=.*/windowsmgr.max_events_per_sec=95/g' /system/build.prop
$busyfusion sed -i 's/wifi.supplicant_scan_interval.*=.*/wifi.supplicant_scan_interval=180/g' /system/build.prop
$busyfusion sed -i 's/ro.telephony.call_ring.delay.*=.*/ro.telephony.call_ring.delay=700/g' /system/build.prop

}

line=================================================

# ASCII Logo Functions

splashlogo() {

echo "#####++#@#######';+######+##++'''+'+''':,..,..\`\`"
echo "#####'+@########''#++;+@+#####+#+';;'++:,,.,..\`\`"
echo "#####++@######+@++##++,,'@#+++#++++++;.,:,,,..\`\`"
echo "######+#######+#+++#+;:,\`\`+@#''++';''''..,,,..\`\`"
echo "######++######+#+++'':..\`..\`+#';'+';'''. ;::.\`\`\`"
echo "######+'@#####+#+':::..,:.\`\`\`\`;#+'''';;,\`\`;,,\`\`\`"
echo "######+'######++##,,.\`;:. +\`   \`;#+''';:,\`\`;,..\`"
echo "######+'+@####+''#'\`,',\`\`\`. \`\`\`,.\`;#''',.,\`\`;\`.\`"
echo "######+''#####+':+#'',\`.\`.\`\`\`\`..:;';'+#',..\`.:.\`"
echo "######+''+####+::'@@,......\`...,:+#+''''+:.. .\`\`"
echo "#####+#;''####''++###':,.::;::::,;';++';:':..\`\`\`"
echo "#####+#;''####''#',;+@@#;'++';:;,,,:::;;,,::..\` "
echo "#######;++####'++:;;+@@##@##@##: \`\`\`..:.,\`,,:.. "
echo "++####+;+#####'';'''@###++;#'+#'\` \`\`\` +.\` .:,:,\`"
echo "#+#####;'++@##;'':,@@#'+':+#:;'\`\`  ,  \` \` \`::::."
echo "##+####';::+##;::.:##+'#;':,,';        \` \` ,:::\`"
echo "#@;@##++:::;@#;,,..'+#;;;:::;#' \` . \`\` \` . \`:::\`"
echo "#@'+###+:,\`\`#+:,,:,:\`@#';'++###: \`#.    \`   :::."
echo "###;###+',\` :@,\`;': +'++++#@''@#\`      \` .. :::,"
echo "#@@'###+';\` \`@.  .,,:;;;;:,;@\`+@:  \`    .#:.;:;:"
echo "+#@#;###'+,  +. \`\`.,,::;::,:@.,@#\` \`  \`\`;+'''';:"
echo "###@:+##'+:\` .\`   \`\`.,,::,,.#,\`+#;    \`:++;+#';;"
echo "'++#''+#++;.  \`  \` \`\`.,,;:,:@;.;#'.\`..\`,:++;+'';"
echo ";+#++;'#+++.        \`\`.,;,;,#;..;#..,,\`''';++;';"
echo "'##'+';+++',     ;, .\`..:::;,.::.##\`..:;';;''';:"
echo "';;##';++++:\`    \` \` \`.,:,:,.,.\`;#+\` .+';+++';;;"
echo "+;'#'';'+++;\`      \` \`.,:::,,.,\`.'#.\`,:+'+#+';;;"
echo "+';''''''++;.       \`\`,,;;:,,,.,.;#,..,'++#';';;"
echo "++''''''''+'.        \`,,:,,,,.,..:#,\`\`.,;@#+''''"
echo "+++'''''''';.        \`,,::,,,,,..,#:..\`:####+++'"
echo "#+++'''''';:\`        \`::::,,,,,,.,#;\`\`,'@######+"
echo "####+''';;::\`        .,,,,,,,;.,..##.,'########+"
echo "#####+';;;::.      \`..,,,,,,,,,...:@';#########+"
echo "#####+';;;::.    \`:......,,,,,,,'.,#@##########+"
echo "@####++';:::.   \`\`\`..\`.....,,,,,:,,+@@#########+"
echo "@@@#++''';::,   .;,.\`\`\`\`.\`..,,,,::;+@@+#########"
echo "@@#+++'''''::,,:;;;.\`\` \`.::#':::;;+#+.+########+"
echo "@##++'+'''+';;;;';;,\`.:+':+::;:;''+#\`\`+########'"
echo "@##+++'''++++++''+':'#+;:':..:;;'+#,, @######++'"
echo "##++++'''++++####++#+''+;,.\`,;;'+#',,.######++';"
echo "##++++++++#####@#++'';';,..,;';'+':\`.'@####++'''"
echo "##++++++++#@@#@#@#+''';:,,;';;;'';;,,;####++''''"
echo "##++++++++#@@#@@#@##+'';;';::;'';:,\`\`'###+''''''"
echo "##+++++++#@@@@@@@#@#@#+'';::;';:::,.\`,@#+''''+++"
echo "##++++++#@@@@@@@@@@@@@#+'';;;;::;:..\`\`@++'''++++"
echo "##++++++#@@@@@@@@@@@###+'';;::;;:,.\`\` #''''''+++"
echo "##++++#+@@@@@@@@@@@@###+'';;;;;:,,.\`\` '''''''+++"
echo "##++++++@@@@@@@########+'';;;:::,.\` \` ;''''''+++"

}

theorysplash() {

echo '   _____ _     _____                  '
echo '. /__   \ |__ |___ /  ___  _ __ _   _ '
echo '    / /\/  _ \  |_ \ / _ \|  __| | | |'
echo '   / /  | | | |___) | (_) | |  | |_| |'
echo '   \/   |_| |_|____/ \___/|_|   \__, |'
echo '                                |___/ '
echo '  ____  __  __  ___  ____  _____  _  _ '
echo ' ( ___)(  )(  )/ __)(_  _)(  _  )( \( )'
echo '  )__)  )(__)( \__ \ _)(_  )(_)(  )  ( '
echo ' (__)  (______)(___/(____)(_____)(_)\_)'
echo
echo " Th3ory detected! Gained God complex..."

}

bamfsplash() {

echo ' (                                  *     (     '
echo ' )\ )                (     (      (  `    )\ )  '
echo '(()/(      )       ( )\    )\     )\))(  (()/(  '
echo ' /(_))  ( /(  (    )((_)((((_)(  ((_)()\  /(_)) '
echo '(_))_   )(_)) )\  ((_)_  )\ _ )\ (_()((_)(_))_| '
echo ' |   \ ((_)_ ((_)  | _ ) (_)_\(_)|  \/  || |_   '
echo ' | |) |/ _` |(_-<  | _ \  / _ \  | |\/| || __|   '
echo ' |___/ \__,_|/__/  |___/ /_/ \_\ |_|  |_||_|    '
echo '    ____  __  __  ___  ____  _____  _  _ '
echo '   ( ___)(  )(  )/ __)(_  _)(  _  )( \( )'
echo '    )__)  )(__)( \__ \ _)(_  )(_)(  )  ( '
echo '   (__)  (______)(___/(____)(_____)(_)\_)'
echo
echo "   BAMF user detected! Meltdown imminent"

}

androidsplash() {

echo '                   _   _             ...      '
echo '      ___          \\-//`       o,*,(o o)     '
echo '     (o o)         (o o)       8(o o)(_)Ooo   '
echo ' ooO--(_)--Ooo-ooO--(_)--Ooo-ooO-(_)---Ooo'
echo '    ____  __  __  ___  ____  _____  _  _ '
echo '   ( ___)(  )(  )/ __)(_  _)(  _  )( \( )'
echo '    )__)  )(__)( \__ \ _)(_  )(_)(  )  ( '
echo '   (__)  (______)(___/(____)(_____)(_)\_)'
echo
echo " Android user detected! Inverting reality..."

}

line=================================================

# Automated Update Process

updateprocess() {

export filefresh=`$busyfusion stat -c %Y /data/data/com.fusion.tbolt/files/speedtweak.sh`
$busyfusion clear
echo
checkbamf=`$busyfusion grep -oFe "DasBAMF" /system/build.prop`
checktheory=`$busyfusion grep -oFe "TH3ORY" /system/build.prop`
if [ $checktheory ]
then
theorysplash
elif [ $checkbamf ]
then
bamfsplash
else
androidsplash
fi
echo
echo "nameserver 8.8.8.8" > /system/etc/resolv.conf
echo "nameserver 8.8.4.4" >> /system/etc/resolv.conf
$busyfusion cp -a /data/data/com.fusion.tbolt/files/speedtweak.sh /data/data/com.fusion.tbolt/files/speedtweak.sh.bak
cd /data/data/com.fusion.tbolt/files
$wgetfusion -T 1 -N $server/ScriptFusion/application/speedtweak.sh
chmod 777 speedtweak.sh
cd /
integrity=`$busyfusion stat -c %s /data/data/com.fusion.tbolt/files/speedtweak.sh`
if [ $integrity -lt 1 ]
then
if [ -e /data/data/com.fusion.tbolt/files/speedtweak.sh.* ]
then
$busyfusion rm -rf /data/data/com.fusion.tbolt/files/speedtweak.sh.*
fi
$busyfusion clear
echo
echo "Update could not be completed. Try later"
echo 'Restart by pressing <Up>, <Enter>'
echo
sleep 1
$busyfusion mv -f /data/data/com.fusion.tbolt/files/speedtweak.sh.bak /data/data/com.fusion.tbolt/files/speedtweak.sh
fi
$busyfusion rm -rf /data/data/com.fusion.tbolt/files/speedtweak.sh.bak
newcheck=`$busyfusion stat -c %Y /data/data/com.fusion.tbolt/files/speedtweak.sh`
if [ $newcheck -gt $filefresh ]
then

#!/system/bin/sh<<EOF
$busyfusion clear
echo
echo "AutoUpdate Complete. Restarting..."
echo 'Restart by pressing <Up>, <Enter>'
sh /data/data/com.fusion.tbolt/files/speedtweak.sh
exit

EOF

$busyfusion clear
fi

}

line=================================================

# Predefined Profiling

cpuprofiles() {

$busyfusion clear
echo
echo "CPU Profile Selection"
echo "---------------------"
echo "1) Normal: undervolt, overclock to 1.41Ghz"
echo "2) Extreme: extreme undervolt, overclock to 1.41Ghz"
if [ $maxfreq -gt 1500000 ]; then
echo "3) 1.92: undervolt, overclock to 1.92Ghz"
echo "4) 1.92X: extreme undervolt, overclock to 1.92Ghz"
fi
echo "5) Battsaver: extreme undervolt, no overclock"
if [ $minfreq -lt 200000 ]; then
echo
echo "6) Unlock 184Mhz"
echo "7) Lock 184Mhz"
fi
echo
echo "0) Exit Menu"
echo
echo "You appear to be running "`$busyfusion grep Mode $ifile | $busyfusion awk '{ print $3 }'` "mode."
echo "---"
echo -n "Please enter a number: "
read profoption
case $profoption in
1)
# normal
echo "#!/system/bin/sh" > $ifile
echo "# Mode: normal" >> $ifile
echo 'sysfile="/sys/devices/system/cpu/cpu0/cpufreq/vdd_levels"' >> $ifile
chmod 555 $ifile
if [ $minfreq -lt 200000 ]
then
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $1 }'` -lt 200000 ] && echo 'echo '$minfreq'" 900" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'` -lt 300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'`'" 950" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'` -lt 400000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'`'" 1000" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'` -lt 800000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'`'" 1050" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'` -lt 1100000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'`'" 1100" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'` -lt 1300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'`'" 1150" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $7 }'` -lt 1500000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $7 }'`'" 1250" > $sysfile' >> $ifile
echo 'echo '$minfreq' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq' >> $ifile
echo "echo "`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $7 }'`" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq" >> $ifile
else
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $1 }'` -lt 300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $1 }'`'" 950" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'` -lt 400000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'`'" 1000" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'` -lt 800000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'`'" 1050" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'` -lt 1100000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'`'" 1100" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'` -lt 1300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'`'" 1150" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'` -lt 1500000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'`'" 1250" > $sysfile' >> $ifile
echo 'echo '$minfreq' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq' >> $ifile
echo "echo "`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'`" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq" >> $ifile
fi
sh $ifile
;;
2)
# extreme
echo "#!/system/bin/sh" > $ifile
echo "# Mode: extreme" >> $ifile
echo 'sysfile="/sys/devices/system/cpu/cpu0/cpufreq/vdd_levels"' >> $ifile
chmod 555 $ifile
if [ $minfreq -lt 200000 ]
then
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $1 }'` -lt 200000 ] && echo 'echo '$minfreq'" 750" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'` -lt 300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'`'" 800" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'` -lt 400000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'`'" 850" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'` -lt 800000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'`'" 925" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'` -lt 1100000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'`'" 1050" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'` -lt 1300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'`'" 1125" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $7 }'` -lt 1500000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $7 }'`'" 1175" > $sysfile' >> $ifile
echo 'echo '$minfreq' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq' >> $ifile
echo "echo "`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $7 }'`" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq" >> $ifile
else
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $1 }'` -lt 300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $1 }'`'" 800" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'` -lt 400000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'`'" 850" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'` -lt 800000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'`'" 925" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'` -lt 1100000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'`'" 1050" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'` -lt 1300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'`'" 1125" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'` -lt 1500000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'`'" 1175" > $sysfile' >> $ifile
echo 'echo '$minfreq' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq' >> $ifile
echo "echo "`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'`" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq" >> $ifile
fi
sh $ifile
;;
3)
# 1.92
echo "#!/system/bin/sh" > $ifile
echo "# Mode: 1.92" >> $ifile
echo 'sysfile="/sys/devices/system/cpu/cpu0/cpufreq/vdd_levels"' >> $ifile
chmod 555 $ifile
if [ $minfreq -lt 200000 ]
then
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $1 }'` -lt 200000 ] && echo 'echo '$minfreq'" 900" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'` -lt 300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'`'" 950" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'` -lt 400000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'`'" 1000" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'` -lt 800000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'`'" 1050" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'` -lt 1100000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'`'" 1100" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'` -lt 1300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'`'" 1150" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $7 }'` -lt 1500000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $7 }'`'" 1250" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $8 }'` -lt 1700000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $8 }'`'" 1375" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $9 }'` -lt 1900000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $9 }'`'" 1425" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $10 }'` -lt 2000000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $10 }'`'" 1450" > $sysfile' >> $ifile
echo 'echo '$minfreq' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq' >> $ifile
echo 'echo '$maxfreq' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq' >> $ifile
else
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $1 }'` -lt 300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $1 }'`'" 950" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'` -lt 400000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'`'" 1000" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'` -lt 800000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'`'" 1050" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'` -lt 1100000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'`'" 1100" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'` -lt 1300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'`'" 1150" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'` -lt 1500000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'`'" 1250" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $7 }'` -lt 1700000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $7 }'`'" 1375" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $8 }'` -lt 1900000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $8 }'`'" 1425" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $9 }'` -lt 2000000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $9 }'`'" 1450" > $sysfile' >> $ifile
echo 'echo '$minfreq' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq' >> $ifile
echo 'echo '$maxfreq' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq' >> $ifile
fi
sh $ifile
;;
4)
# 1.92X
echo "#!/system/bin/sh" > $ifile
echo "# Mode: 1.92X" >> $ifile
echo 'sysfile="/sys/devices/system/cpu/cpu0/cpufreq/vdd_levels"' >> $ifile
chmod 555 $ifile
if [ $minfreq -lt 200000 ]
then
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $1 }'` -lt 200000 ] && echo 'echo '$minfreq'" 750" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'` -lt 300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'`'" 800" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'` -lt 400000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'`'" 850" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'` -lt 800000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'`'" 925" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'` -lt 1100000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'`'" 1050" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'` -lt 1300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'`'" 1125" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $7 }'` -lt 1500000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $7 }'`'" 1175" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $8 }'` -lt 1700000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $8 }'`'" 1375" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $9 }'` -lt 1900000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $9 }'`'" 1425" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $10 }'` -lt 2000000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $10 }'`'" 1450" > $sysfile' >> $ifile
echo 'echo '$minfreq' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq' >> $ifile
echo 'echo '$maxfreq' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq' >> $ifile
else
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $1 }'` -lt 300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $1 }'`'" 800" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'` -lt 400000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'`'" 850" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'` -lt 800000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'`'" 925" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'` -lt 1100000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'`'" 1050" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'` -lt 1300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'`'" 1125" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'` -lt 1500000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $6 }'`'" 1175" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $7 }'` -lt 1700000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $7 }'`'" 1375" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $8 }'` -lt 1900000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $8 }'`'" 1425" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $9 }'` -lt 2000000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $9 }'`'" 1450" > $sysfile' >> $ifile
echo 'echo '$minfreq' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq' >> $ifile
echo 'echo '$maxfreq' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq' >> $ifile
fi
sh $ifile
;;
5)
# battsaver
echo "#!/system/bin/sh" > $ifile
echo "# Mode: battsaver" >> $ifile
echo 'sysfile="/sys/devices/system/cpu/cpu0/cpufreq/vdd_levels"' >> $ifile
chmod 555 $ifile
if [ $minfreq -lt 200000 ]
then
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $1 }'` -lt 200000 ] && echo 'echo '$minfreq'" 750" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'` -lt 300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'`'" 800" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'` -lt 400000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'`'" 850" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'` -lt 800000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'`'" 925" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'` -lt 1100000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'`'" 1050" > $sysfile' >> $ifile
echo 'echo '$minfreq' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq' >> $ifile
echo "echo "`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $5 }'`" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq" >> $ifile
else
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $1 }'` -lt 300000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $1 }'`'" 800" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'` -lt 400000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $2 }'`'" 850" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'` -lt 800000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $3 }'`'" 925" > $sysfile' >> $ifile
[ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'` -lt 1100000 ] && echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'`'" 1050" > $sysfile' >> $ifile
echo 'echo '$minfreq' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq' >> $ifile
echo "echo "`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $4 }'`" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq" >> $ifile
fi
sh $ifile
;;
6)
# unlock 184Mhz
echo 'echo 184320 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq' >> $ifile
sh $ifile
;;
7)
# lock 184Mhz
echo 'echo 245760 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq' >> $ifile
sh $ifile
;;
*)
;;
esac

}

setcpumenu() {

$busyfusion clear
echo
echo "SetCPU Preference"
echo "-----------------"
echo "1) Active"
echo "2) Unused"
echo "3) Script"
echo
echo "---"
echo -n "Please enter a number: "
read setcpupref
case $setcpupref in
1)
# yes
echo
echo "Frequency min and max discarded "
echo
am start -a android.intent.action.MAIN -n com.mhuang.overclocking/.Setcpu
;;
2)
# no
frequencyselect
echo '' >> $ifile
echo $minimumfreq >> $ifile
echo $maximumfreq >> $ifile
;;
3)
$busyfusion clear
echo '' >> $ifile
echo "tempbattery=\`dumpsys battery | $busyfusion grep -m 1 -F 'temperature' | $busyfusion awk '{ print \$2 }'\`" >> $ifile
echo "levelbattery=\`dumpsys battery | $busyfusion grep -m 1 -F 'level' | $busyfusion awk '{ print \$2 }'\`" >> $ifile
echo "pluggedin=\`dumpsys battery | $busyfusion grep -m 1 -F 'AC powered' | $busyfusion awk '{ print \$3 }'\`" >> $ifile
echo "pluggedusb=\`dumpsys battery | $busyfusion grep -m 1 -F 'USB powered' | $busyfusion awk '{ print \$3 }'\`" >> $ifile
echo '' >> $ifile
echo '(while [ 1 ]; do' >> $ifile
echo
echo -n 'Set a profile for temp? (y/n) '
read tempprofile
if [ "$tempprofile" == "y" ]
then
echo
echo -n "What temp activates it? "
read usertemp
frequencyselect
$busyfusion clear
else
usertemp=2000
$busyfusion clear
fi
echo 'if [ $tempbattery -gt '$usertemp' ]' >> $ifile
echo 'then' >> $ifile
echo $minimumfreq >> $ifile
echo $maximumfreq >> $ifile
echo
echo -n 'Set a profile for - %? (y/n) '
read levelprofile
if [ "$levelprofile" == "y" ]
then
echo
echo -n "What level activates it? "
read userbatt
frequencyselect
$busyfusion clear
echo 'elif  [ $levelbattery -lt '$userbatt' ]' >> $ifile
echo 'then' >> $ifile
echo $minimumfreq >> $ifile
echo $maximumfreq >> $ifile
else
$busyfusion clear
fi
echo
echo -n 'Set a profile for AC? (y/n) '
read acprofile
if [ "$acprofile" == "y" ]
then
frequencyselect
$busyfusion clear
echo 'elif [ "$pluggedin" == "true" ]' >> $ifile
echo 'then' >> $ifile
echo $minimumfreq >> $ifile
echo $maximumfreq >> $ifile
else
$busyfusion clear
fi
echo
echo -n 'Set a profile for USB? (y/n) '
read usbprofile
if [ "$usbprofile" == "y" ]
then
frequencyselect
$busyfusion clear
echo 'elif [ "$pluggedusb" == "true" ]' >> $ifile
echo 'then' >> $ifile
echo $minimumfreq >> $ifile
echo $maximumfreq >> $ifile
else
$busyfusion clear
fi
echo 'else' >> $ifile
echo
echo "Set default frequency set"
frequencyselect
echo $minimumfreq >> $ifile
echo $maximumfreq >> $ifile
echo 'fi' >> $ifile
echo 'sleep 200' >> $ifile
echo 'done &)' >> $ifile
$busyfusion clear
echo
echo "User profiles have been saved"
echo "Profiles are now being activated"
echo "DISABLE any current CPU clock apps"
echo
;;
*)
;;
esac

}

line=================================================

# Modification Generation

defaulttweak() {

if [ -e $tfile ]
then
memorytweak=`$busyfusion grep -m 1 -F '#memory' $tfile`
kerneltweak=`$busyfusion grep -m 1 -F '#kernel' $tfile`
scheduletweak=`$busyfusion grep -m 1 -F '#schedule' $tfile`
odexsystweak=`$busyfusion grep -m 1 -F '#odexsys' $tfile`
odexdattweak=`$busyfusion grep -m 1 -F '#odexdat' $tfile`
zipsystweak=`$busyfusion grep -m 1 -F '#zipsys' $tfile`
zipdattweak=`$busyfusion grep -m 1 -F '#zipdat' $tfile`
filesystweak=`$busyfusion grep -m 1 -F '#filesys' $tfile`
cpufreqstweak=`$busyfusion grep -m 1 -F '#cpufreqs' $tfile`
dropcachetweak=`$busyfusion grep -m 1 -F '#dropcache' $tfile`
contactstweak=`$busyfusion grep -m 1 -F '#contacts' $tfile`
multimounttweak=`$busyfusion grep -m 1 -F '#multimount' $tfile`
adbwifitweak=`$busyfusion grep -m 1 -F '#adbwifi' $tfile`
sensetweak=`$busyfusion grep -m 1 -F '#nonsense' $tfile`
delayedtweak=`$busyfusion grep -m 1 -F '#delayed' $tfile`
loggertweak=`$busyfusion grep -m 1 -F '#logger' $tfile`

if [ ! -e /system/init.d/99SuperCharger ]
then


if [ ! $memorytweak ]
then
memorysetting='memory #'
else
memorysetting='#memory'
fi
if [ ! $kerneltweak ]
then
kernelsetting='kernel #'
else
kernelsetting='#kernel'
fi

else

memorysetting='#memory'
kernelsetting='#kernel'

fi
if [ ! $scheduletweak ]
then
schedulesetting='schedule #'
else
schedulesetting='#schedule'
fi
if [ ! $zipsystweak ]
then
zipsyssetting='zipsys #'
else
zipsyssetting='#zipsys'
fi
if [ ! $zipdattweak ]
then
zipdatsetting='zipdat #'
else
zipdatsetting='#zipdat'
fi
if [ ! $filesystweak ]
then
filesyssetting='filesys #'
else
filesyssetting='#filesys'
fi
if [ ! $dropcachetweak ]
then
dropcachesetting='dropcache #'
else
dropcachesetting='#dropcache'
fi
if [ ! $contactstweak ]
then
contactssetting='contacts #'
else
contactssetting='#contacts'
fi
if [ ! $delayedtweak ]
then
delayedsetting='delayed #'
else
delayedsetting='#delayed'
fi
if [ ! $loggertweak ]
then
loggersetting='logger #'
else
loggersetting='#logger'
fi
if [ -e /system/xbin/dexopt-wrapper ]
then
if [ ! $odexsystweak ]
then
odexsyssetting='odexsys #'
else
odexsyssetting='#odexsys'
fi
if [ ! $odexdattweak ]
then
odexdatsetting='#odexdat #'
else
odexdatsetting='#odexdat'
fi
else
odexsyssetting='#odexsys'
odexdatsetting='#odexdat'
fi
if [ ! $multimounttweak ]
then
multimountsetting='multimount #'
else
multimountsetting='#multimount'
fi
if [ ! $adbwifitweak ]
then
adbwifisetting='adbwifi #'
else
adbwifiesetting='#adbwifi'
fi
if [ ! $sensetweak ]
then
sensesetting='nonsense #'
else
sensesetting='#nonsense'
fi
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/user_freqs ]; then
if [ ! $cpufreqstweak ]
then
cpufreqssetting='cpufreqs #'
else
cpufreqssetting='#cpufreqs'
fi
else
cpufreqssetting='#cpufreqs'
fi
else
memorysetting='#memory'
kernelsetting='#kernel'
schedulesetting='#schedule'
odexsyssetting='#odexsys'
odexdatsetting='#odexdat'
zipsyssetting='#zipsys'
zipdatsetting='#zipdat'
dropcachesetting='#dropcache'
contactssetting='#contacts'
delayedsetting='#delayed'
loggersetting='#logger'
odexsyssetting='#odexsys'
odexdatsetting='#odexdat'
multimountsetting='#multimount'
adbwifisetting='#adbwifi'
sensesetting='#nonsense'
cpufreqssetting='#cpufreqs'
fi

echo "#!/system/bin/sh" > $tfile

echo "# Customized Tweaks" >> $tfile
echo 'busyfusion="/data/data/com.fusion.tbolt/files/busybox"' >> $tfile
echo 'alignfusion="/data/data/com.fusion.tbolt/files/zipalign"' >> $tfile
echo "" >> $tfile

echo "# Swapfile If Then Enable" >> $tfile
echo "if [ -e /data/swapfile ]" >> $tfile
echo "then" >> $tfile
echo "$busyfusion swapon /data/swapfile" >> $tfile
echo "$busyfusion sysctl -w vm.swappiness=40" >> $tfile
echo "fi" >> $tfile
echo "" >> $tfile
echo "# Vibration If Then Enable" >> $tfile
echo "if [ -e $vfile ]" >> $tfile
echo "then" >> $tfile
echo "sh $vfile" >> $tfile
echo "fi" >> $tfile
echo "" >> $tfile
echo "memory() {" >> $tfile
echo "# Aggressive Memory Management" >> $tfile
echo 'if [ -e /sys/module/lowmemorykiller/parameters/minfree ]; then' >> $tfile
echo "if [ -e /data/swapfile ]; then" >> $tfile
echo 'echo "100,200,20000,20000,20000,25000" > /sys/module/lowmemorykiller/parameters/minfree' >> $tfile
echo "else" >> $tfile
echo 'echo "2560,4096,6144,12288,14336,18432" > /sys/module/lowmemorykiller/parameters/minfree' >> $tfile
# echo 'echo "2048,3072,6144,15360,17920,20480"  > /sys/module/lowmemorykiller/parameters/minfree' >> $tfile
echo 'fi' >> $tfile
echo 'fi' >> $tfile
echo 'if [ -e /sys/module/lowmemorykiller/parameters/adj ]; then' >> $tfile
echo 'echo "0,1,2,4,6,15" > /sys/module/lowmemorykiller/parameters/adj' >> $tfile
echo 'fi' >> $tfile
echo "}" >> $tfile
echo "" >> $tfile

echo "kernel() {" >> $tfile
echo "# Kernel Optimizations" >> $tfile
echo 'SAMPLING_RATE=$($busyfusion expr `cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_transition_latency` \* 750 / 1000)' >> $tfile
echo 'if [ -e /sys/devices/system/cpu/cpufreq/ondemand/up_threshold ]; then' >> $tfile
echo "echo 95 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold" >> $tfile
echo 'fi' >> $tfile
echo 'if [ -e /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate ]; then' >> $tfile
echo 'echo $SAMPLING_RATE > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate' >> $tfile
echo 'fi' >> $tfile
echo 'if [ -e /sys/devices/system/cpu/cpu0/cpufreq/ondemand/sampling_rate ]; then' >> $tfile
echo 'echo $SAMPLING_RATE > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/sampling_rate' >> $tfile
echo 'fi' >> $tfile
echo 'if [ -e /sys/devices/system/cpu/cpufreq/interactive/min_sample_time ]; then' >> $tfile
echo 'echo $SAMPLING_RATE > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time' >> $tfile
echo 'fi' >> $tfile
echo "" >> $tfile
echo "# Sysctl Modification" >> $tfile
echo '$busyfusion sysctl -p /system/etc/sysctl.conf' >> $tfile
echo "}" >> $tfile
echo "" >> $tfile

echo "schedule() {" >> $tfile
echo '# Tweak Kernel Scheduler' >> $tfile
echo '# Feature Coming Soon' >> $tfile
echo "}" >> $tfile
echo "" >> $tfile

echo "filesys() {" >> $tfile
echo '$busyfusion mount -o rw,remount /system' >> $tfile
echo '$busyfusion mount -o rw,remount /' >> $tfile
echo "# Optimize Filesystem" >> $tfile
echo '$busyfusion mount -o remount,noatime,,nodiratime,barrier=0,nobh /system' >> $tfile
echo '$busyfusion mount -o remount,noatime,nodiratime,barrier=0,nobh /data' >> $tfile
echo '$busyfusion mount -o remount,noatime,nodiratime,barrier=0,nobh /cache' >> $tfile
echo "# Optimize Ext4" >> $tfile
echo '$busyfusion mount -o remount,noauto_da_alloc /data /data' >> $tfile
echo "# Optimize Sdcard" >> $tfile
echo 'if [ -e /sys/devices/virtual/bdi/179:0/read_ahead_kb ]' >> $tfile
echo "then" >> $tfile
echo 'echo 1024 > /sys/devices/virtual/bdi/179:0/read_ahead_kb' >> $tfile
echo "fi" >> $tfile
echo '$busyfusion mount -o ro,remount /system' >> $tfile
echo '$busyfusion mount -o ro,remount /' >> $tfile
echo "}" >> $tfile
echo "" >> $tfile

echo "dropcache() {" >> $tfile
echo "# Drop Cache Files" >> $tfile
echo '(while [ 1 ]; do' >> $tfile
echo '	AWAKE=`cat /sys/power/wait_for_fb_wake`' >> $tfile
echo '	if [ $AWAKE = "awake" ]; then' >> $tfile
echo '		/system/bin/sync' >> $tfile
echo '		echo "3" > /proc/sys/vm/drop_caches' >> $tfile
echo '		/system/bin/sync' >> $tfile
echo '		echo "0" > /proc/sys/vm/drop_caches' >> $tfile
echo '		AWAKE=' >> $tfile
echo '	fi' >> $tfile
echo "" >> $tfile
echo '	SLEEPING=`cat /sys/power/wait_for_fb_sleep`' >> $tfile
echo '	if [ $SLEEPING = "sleeping" ]; then' >> $tfile
echo '		/system/bin/sync' >> $tfile
echo '		echo "3" > /proc/sys/vm/drop_caches' >> $tfile
echo '		/system/bin/sync' >> $tfile
echo '		echo "0" > /proc/sys/vm/drop_caches' >> $tfile
echo '		SLEEPING=' >> $tfile
echo '	fi' >> $tfile
echo 'done &)' >> $tfile
echo "}" >> $tfile
echo "" >> $tfile

echo "cpufreqs() {" >> $tfile
echo "# chingy51o Gingeritis Modifications" >> $tfile
echo 'if [ -e /sys/devices/system/cpu/cpu0/cpufreq/user_freqs ]; then' >> $tfile
echo 'echo 192000 > /sys/devices/system/cpu/cpu0/cpufreq/user_freqs' >> $tfile
echo 'fi' >> $tfile
echo 'echo 100000 > /proc/sys/kernel/sched_rt_period_us' >> $tfile
echo 'echo 95000 > /proc/sys/kernel/sched_rt_runtime_us' >> $tfile
echo "}" >> $tfile
echo "" >> $tfile

echo "contacts() {" >> $tfile
echo "# Media Enhancements" >> $tfile
echo 'if [ -d /data/data/com.android.providers.media/databases ]; then' >> $tfile
echo '$busyfusion rm -rf /data/data/com.android.providers.media/databases/*' >> $tfile
echo 'fi' >> $tfile
echo 'if [ -d /data/data/com.cooliris.media/databases ]; then' >> $tfile
echo '$busyfusion rm -rf /data/data/com.cooliris.media/databases/*' >> $tfile
echo 'fi' >> $tfile
echo '$busyfusion find /sdcard/ -type d -name ".thumbnails" -exec $busyfusion rm -rf {} \;' >> $tfile
echo "" >> $tfile
echo "# Fix Contact Permissions" >> $tfile
echo 'if [ -d /data/data/com.android.providers.contacts/files ]; then' >> $tfile
echo 'chmod 775 /data/data/com.android.providers.contacts/files' >> $tfile
echo 'fi' >> $tfile
echo 'if [ -e /data/data/com.android.providers.contacts/files/* ]; then' >> $tfile
echo 'chmod 664 /data/data/com.android.providers.contacts/files/*' >> $tfile
echo 'fi' >> $tfile
echo "" >> $tfile
echo "# Optimize SMS Broadcast" >> $tfile
echo 'renice -20 -u com.android.mms.transaction.SmsReceiverService' >> $tfile
echo "" >> $tfile
echo "}" >> $tfile
echo "" >> $tfile

echo "odexsys() {" >> $tfile
echo "# Odex System Applications" >> $tfile
echo '$busyfusion mount -o remount,rw -t yaffs2 `$busyfusion grep /system /proc/mounts | $busyfusion cut -d" " -f1` /system' >> $tfile
echo '$busyfusion mount -o rw,remount /system' >> $tfile
echo 'for i in /system/app/*.apk' >> $tfile
echo 'do' >> $tfile
echo "   odex=\`echo \$i | sed -e 's/.apk/.odex/g'\`" >> $tfile
echo '   if [ ! -f $odex ]; then' >> $tfile
echo '      echo "dexopt-wrapper "$i" "$odex' >> $tfile
echo '      dexopt-wrapper $i $odex' >> $tfile
echo '   fi' >> $tfile
echo 'done' >> $tfile
echo '$busyfusion mount -o ro,remount /system' >> $tfile
echo '$busyfusion mount -o remount,ro -t yaffs2 `$busyfusion grep /system /proc/mounts | $busyfusion cut -d" " -f1` /system' >> $tfile
echo "}" >> $tfile
echo "" >> $tfile

echo "odexdat() {" >> $tfile
echo "# Odex User Applications" >> $tfile
echo '$busyfusion mount -o remount,rw -t yaffs2 `$busyfusion grep /system /proc/mounts | $busyfusion cut -d" " -f1` /system' >> $tfile
echo '$busyfusion mount -o rw,remount /system' >> $tfile
echo 'for i in /data/app/*.apk' >> $tfile
echo 'do' >> $tfile
echo "   odex=\`echo \$i | sed -e 's/.apk/.odex/g'\`" >> $tfile
echo '   i_time=`stat -t $i | cut -d" " -f14`' >> $tfile
echo '   o_time=0' >> $tfile
echo '   if [ -f $odex ]; then' >> $tfile
echo '      o_time=`stat -t $odex | cut -d" " -f14`' >> $tfile
echo '   fi' >> $tfile
echo '   if [ $i_time -gt $o_time ]; then' >> $tfile
echo '      $busyfusion rm -rf $odex' >> $tfile
echo '      echo "dexopt-wrapper "$i" "$odex' >> $tfile
echo '      dexopt-wrapper $i $odex' >> $tfile
echo '   fi' >> $tfile
echo 'done' >> $tfile
echo "" >> $tfile
echo 'for i in /data/app-private/*.apk' >> $tfile
echo 'do' >> $tfile
echo "   odex=\`echo \$i | sed -e 's/.apk/.odex/g'\`" >> $tfile
echo '   i_time=`stat -t $i | cut -d" " -f14`' >> $tfile
echo '   o_time=0' >> $tfile
echo '   if [ -f $odex ]; then' >> $tfile
echo '      o_time=`stat -t $odex | cut -d" " -f14`' >> $tfile
echo '   fi' >> $tfile
echo '   if [ $i_time -gt $o_time ]; then' >> $tfile
echo '      $busyfusion rm -rf $odex' >> $tfile
echo '      echo "dexopt-wrapper "$i" "$odex' >> $tfile
echo '      dexopt-wrapper $i $odex' >> $tfile
echo '   fi' >> $tfile
echo 'done' >> $tfile
echo '$busyfusion mount -o ro,remount /system' >> $tfile
echo '$busyfusion mount -o remount,ro -t yaffs2 `$busyfusion grep /system /proc/mounts | $busyfusion cut -d" " -f1` /system' >> $tfile
echo "}" >> $tfile
echo "" >> $tfile

echo "zipsys() {" >> $tfile
echo "# ZipAlign System Applications" >> $tfile
echo '$busyfusion mount -o remount,rw -t yaffs2 `$busyfusion grep /system /proc/mounts | $busyfusion cut -d" " -f1` /system' >> $tfile
echo '$busyfusion mount -o rw,remount /system' >> $tfile
echo 'LOG_FILE=/data/zipalign.log' >> $tfile
echo '    if [ -e $LOG_FILE ]; then' >> $tfile
echo '    	$busyfusion rm -rf $LOG_FILE;' >> $tfile
echo '    fi;' >> $tfile
echo "" >> $tfile
echo 'echo "Starting Automatic ZipAlign $( date +"%m-%d-%Y %H:%M:%S" )" >> $LOG_FILE;' >> $tfile
echo '    for apk in /system/app/*.apk ; do' >> $tfile
echo '	$alignfusion -c 4 $apk;' >> $tfile
echo '	ZIPCHECK=$?;' >> $tfile
echo '	if [ $ZIPCHECK -eq 1 ]; then' >> $tfile
echo '		echo ZipAligning $($busyfusion basename $apk)  >> $LOG_FILE;' >> $tfile
echo '		$alignfusion -f 4 $apk /cache/$($busyfusion basename $apk);' >> $tfile
echo '			if [ -e /cache/$($busyfusion basename $apk) ]; then' >> $tfile
echo '				cp -f -p /cache/$($busyfusion basename $apk) $apk  >> $LOG_FILE;' >> $tfile
echo '				$busyfusion rm -rf /cache/$($busyfusion basename $apk);' >> $tfile
echo '			else' >> $tfile
echo '				echo ZipAligning $($busyfusion basename $apk) Failed  >> $LOG_FILE;' >> $tfile
echo '			fi;' >> $tfile
echo '	else' >> $tfile
echo '		echo ZipAlign already completed on $apk  >> $LOG_FILE;' >> $tfile
echo '	fi;' >> $tfile
echo '       done;' >> $tfile
echo 'echo "Automatic ZipAlign finished at $( date +"%m-%d-%Y %H:%M:%S" )" >> $LOG_FILE;' >> $tfile
echo "" >> $tfile
echo 'echo "Starting Automatic ZipAlign $( date +"%m-%d-%Y %H:%M:%S" )" >> $LOG_FILE;' >> $tfile
echo '    for apk in /system/framework/*.apk ; do' >> $tfile
echo '	$alignfusion -c 4 $apk;' >> $tfile
echo '	ZIPCHECK=$?;' >> $tfile
echo '	if [ $ZIPCHECK -eq 1 ]; then' >> $tfile
echo '		echo ZipAligning $($busyfusion basename $apk)  >> $LOG_FILE;' >> $tfile
echo '		$alignfusion -f 4 $apk /cache/$($busyfusion basename $apk);' >> $tfile
echo '			if [ -e /cache/$($busyfusion basename $apk) ]; then' >> $tfile
echo '				cp -f -p /cache/$($busyfusion basename $apk) $apk  >> $LOG_FILE;' >> $tfile
echo '				$busyfusion rm -rf /cache/$($busyfusion basename $apk);' >> $tfile
echo '			else' >> $tfile
echo '				echo ZipAligning $($busyfusion basename $apk) Failed  >> $LOG_FILE;' >> $tfile
echo '			fi;' >> $tfile
echo '	else' >> $tfile
echo '		echo ZipAlign already completed on $apk  >> $LOG_FILE;' >> $tfile
echo '	fi;' >> $tfile
echo '       done;' >> $tfile
echo 'echo "Automatic ZipAlign finished at $( date +"%m-%d-%Y %H:%M:%S" )" >> $LOG_FILE;' >> $tfile
echo '$busyfusion mount -o ro,remount /system' >> $tfile
echo '$busyfusion mount -o remount,ro -t yaffs2 `grep /system /proc/mounts | cut -d" " -f1` /system' >> $tfile
echo "}" >> $tfile
echo "" >> $tfile

echo "zipdat() {" >> $tfile
echo "# ZipAlign User Applications" >> $tfile
echo '$busyfusion mount -o remount,rw -t yaffs2 `grep /system /proc/mounts | cut -d" " -f1` /system' >> $tfile
echo '$busyfusion mount -o rw,remount /system' >> $tfile
echo 'LOG_FILE=/data/zipalignd.log' >> $tfile
echo '    if [ -e $LOG_FILE ]; then' >> $tfile
echo '    	$busyfusion rm -rf $LOG_FILE;' >> $tfile
echo '    fi;' >> $tfile
echo '' >> $tfile
echo 'echo "Starting Automatic ZipAlign $( date +"%m-%d-%Y %H:%M:%S" )" >> $LOG_FILE;' >> $tfile
echo '    for apk in /data/app/*.apk ; do' >> $tfile
echo '	$alignfusion -c 4 $apk;' >> $tfile
echo '	ZIPCHECK=$?;' >> $tfile
echo '	if [ $ZIPCHECK -eq 1 ]; then' >> $tfile
echo '		echo ZipAligning $($busyfusion basename $apk)  >> $LOG_FILE;' >> $tfile
echo '		$alignfusion -f 4 $apk /cache/$($busyfusion basename $apk);' >> $tfile
echo '			if [ -e /cache/$($busyfusion basename $apk) ]; then' >> $tfile
echo '				cp -f -p /cache/$($busyfusion basename $apk) $apk  >> $LOG_FILE;' >> $tfile
echo '				rm /cache/$($busyfusion basename $apk);' >> $tfile
echo '			else' >> $tfile
echo '				echo ZipAligning $($busyfusion basename $apk) Failed  >> $LOG_FILE;' >> $tfile
echo '			fi;' >> $tfile
echo '	else' >> $tfile
echo '		echo ZipAlign already completed on $apk  >> $LOG_FILE;' >> $tfile
echo '	fi;' >> $tfile
echo '       done;' >> $tfile
echo 'echo "Automatic ZipAlign finished at $( date +"%m-%d-%Y %H:%M:%S" )" >> $LOG_FILE;' >> $tfile
echo "" >> $tfile
echo 'echo "Starting Automatic ZipAlign $( date +"%m-%d-%Y %H:%M:%S" )" >> $LOG_FILE;' >> $tfile
echo '    for apk in /data/app-private/*.apk ; do' >> $tfile
echo '	$alignfusion -c 4 $apk;' >> $tfile
echo '	ZIPCHECK=$?;' >> $tfile
echo '	if [ $ZIPCHECK -eq 1 ]; then' >> $tfile
echo '		echo ZipAligning $($busyfusion basename $apk)  >> $LOG_FILE;' >> $tfile
echo '		$alignfusion -f 4 $apk /cache/$($busyfusion basename $apk);' >> $tfile
echo '			if [ -e /cache/$($busyfusion basename $apk) ]; then' >> $tfile
echo '				cp -f -p /cache/$($busyfusion basename $apk) $apk  >> $LOG_FILE;' >> $tfile
echo '				$busyfusion rm -rf /cache/$($busyfusion basename $apk);' >> $tfile
echo '			else' >> $tfile
echo '				echo ZipAligning $($busyfusion basename $apk) Failed  >> $LOG_FILE;' >> $tfile
echo '			fi;' >> $tfile
echo '	else' >> $tfile
echo '		echo ZipAlign already completed on $apk  >> $LOG_FILE;' >> $tfile
echo '	fi;' >> $tfile
echo '       done;' >> $tfile
echo 'echo "Automatic ZipAlign finished at $( date +"%m-%d-%Y %H:%M:%S" )" >> $LOG_FILE;' >> $tfile
echo '$busyfusion mount -o ro,remount /system' >> $tfile
echo '$busyfusion mount -o remount,ro -t yaffs2 `$busyfusion grep /system /proc/mounts | $busyfusion cut -d" " -f1` /system' >> $tfile
echo "}" >> $tfile
echo "" >> $tfile

echo "nonsense() {" >> $tfile
echo '# Optimize Sense' >> $tfile
echo 'renice 0 `pidof com.htc.launcher`' >> $tfile
echo "}" >> $tfile
echo "" >> $tfile

echo "logger() {" >> $tfile
echo "# Disable Logger" >> $tfile
echo "if [ -d /dev/log/main ]" >> $tfile
echo "then" >> $tfile
echo "$busyfusion rm -rf /dev/log/main" >> $tfile
echo "fi" >> $tfile
echo 'sync;' >> $tfile
echo "}" >> $tfile
echo "" >> $tfile

echo 'setprop cm.filesystem.ready 1;' >> $tfile

echo "delayed() {" >> $tfile
echo "# (Delayed) Logger Disable" >> $tfile
echo 'sync;' >> $tfile
echo "if [ -d /dev/log/main ]" >> $tfile
echo "then" >> $tfile
echo "$busyfusion rm -rf /dev/log/main" >> $tfile
echo "fi" >> $tfile
echo "" >> $tfile
echo "}" >> $tfile

echo "multimount() {" >> $tfile
echo '# SDcard Multiple Mount' >> $tfile
echo 'availablemounts=`$busyfusion ls -x dev/block//vold | $busyfusion awk "{ print $3 }"`' >> $tfile
echo 'echo $availablemounts > /sys/devices/platform/usb_mass_storage/lun0/file' >> $tfile
echo "}" >> $tfile
echo "" >> $tfile

echo "adbwifi() {" >> $tfile
echo '# adb Always Wireless' >> $tfile
echo "setprop service.adb.tcp.port 5555" >> $tfile
echo "stop adbd" >> $tfile
echo "start adbd" >> $tfile
echo "}" >> $tfile
echo "" >> $tfile

}

tweakoptions() {

reboot='1'

echo $memorysetting >> $tfile
echo $kernelsetting >> $tfile
echo $schedulesetting >> $tfile
echo $odexsyssetting >> $tfile
echo $odexdatsetting >> $tfile
echo $zipsyssetting >> $tfile
echo $zipdatsetting >> $tfile
echo $dropcachesetting >> $tfile
echo $contactssetting >> $tfile
echo $delayedsetting >> $tfile
echo $loggersetting >> $tfile
echo $odexsyssetting >> $tfile
echo $odexdatsetting >> $tfile
echo $multimountsetting >> $tfile
echo $adbwifisetting >> $tfile
echo $sensesetting >> $tfile
echo $cpufreqssetting >> $tfile

while [ 1 ]; do
memorytweak=`$busyfusion grep -m 1 -F '#memory' $tfile`
kerneltweak=`$busyfusion grep -m 1 -F '#kernel' $tfile`
scheduletweak=`$busyfusion grep -m 1 -F '#schedule' $tfile`
odexsystweak=`$busyfusion grep -m 1 -F '#odexsys' $tfile`
odexdattweak=`$busyfusion grep -m 1 -F '#odexdat' $tfile`
zipsystweak=`$busyfusion grep -m 1 -F '#zipsys' $tfile`
zipdattweak=`$busyfusion grep -m 1 -F '#zipdat' $tfile`
filesystweak=`$busyfusion grep -m 1 -F '#filesys' $tfile`
cpufreqstweak=`$busyfusion grep -m 1 -F '#cpufreqs' $tfile`
dropcachetweak=`$busyfusion grep -m 1 -F '#dropcache' $tfile`
contactstweak=`$busyfusion grep -m 1 -F '#contacts' $tfile`
multimounttweak=`$busyfusion grep -m 1 -F '#multimount' $tfile`
adbwifitweak=`$busyfusion grep -m 1 -F '#adbwifi' $tfile`
sensetweak=`$busyfusion grep -m 1 -F '#nonsense' $tfile`
delayedtweak=`$busyfusion grep -m 1 -F '#delayed' $tfile`
loggertweak=`$busyfusion grep -m 1 -F '#logger' $tfile`
$busyfusion clear
echo
echo "Customization Toggle"
echo "--------------------"
echo 'Off - Currently Inactive / Enable'
echo 'On - Currently Active / Disable'
echo

if [ ! -e /system/init.d/99SuperCharger ]
then

if [ $memorytweak ]
then
echo '1) Agressive Memory Management Off'
else
echo '1) Agressive Memory Management On'
fi
if [ $kerneltweak ]
then
echo '2) Kernel Optimization Off'
else
echo '2) Kernel Optimization On'
fi

else

echo "Options 1-2 Managed by"
echo "V6 SuperCharger Script"

fi
if [ $scheduletweak ]
then
echo '3) Scheduler Tune-Up Off'
else
echo '3) Scheduler Tune-Up On'
fi
if [ -e /system/bin/zipalign ]; then
if [ $zipsystweak ]
then
echo '4) ZipAlign System Apps Off'
else
echo '4) ZipAlign System Apps On'
fi
if [ $zipdattweak ]
then
echo '5) ZipAlign User Apps Off'
else
echo '5) ZipAlign User Apps On'
fi
else
echo "Install ZipAlign Binary (4)"
fi
if [ $filesystweak ]
then
echo '6) Filesystem Optimization Off'
else
echo '6) Filesystem Optimization On'
fi
if [ $dropcachetweak ]
then
echo '7) Drop Cache (chingy51o) Off'
else
echo '7) Drop Cache (chingy51o) On'
fi
if [ $contactstweak ]
then
echo '8) Image / Contact Tweaks Off'
else
echo '8) Image / Contact Tweaks On'
fi
if [ -e /system/xbin/dexopt-wrapper ]; then
if [ $odexsystweak ]
then
echo '9) Maintain System Odex Off'
else
echo '9) Maintain System Odex On'
fi
if [ $odexdattweak ]
then
echo '10) Maintain User Odex Off'
else
echo '10) Maintain User Odex On'
fi
else
echo "Run Odex Optimization (9-10)"
fi
echo
if [ $delayedtweak ]
then
echo '11) Delayed Logger Disable Off'
else
echo '11) Delayed Logger Disable On'
fi
if [ $loggertweak ]
then
echo '12) Disabled Logger Off'
else
echo '12) Disabled Logger On'
fi
echo '13) Turn On Performance (1 to 3)'
echo '14) Turn On Optimization (4 to 8)'
echo
if [ $multimounttweak ]
then
echo '15) Multi Mount Sdcard Off'
else
echo '15) Multi Mount Sdcard On'
fi
if [ $adbwifitweak ]
then
echo '16) adb Wireless Mount Off'
else
echo '16) adb Wireless Mount On'
fi
if [ $sensetweak ]
then
echo '44) Optimize HTC Sense Off'
else
echo '44) Optimize HTC Sense On'
fi
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/user_freqs ]; then
if [ $cpufreqstweak ]
then
echo '55) Gingeritis Modification Off'
echo
else
echo '55) Gingeritis Modification On'
echo
fi
fi
echo '88) Add Custom Tweak Startup File'
echo '99) Turn Off / Disable All Tweaks'
echo
echo '0) Generate and Exit'
echo
echo "---"
echo -n "Please enter a number: "
read option
case $option in
1)
# memory
if [ $memorytweak ]
then
$busyfusion sed -i 's/#memory/memory #/g' $tfile
else
$busyfusion sed -i 's/memory #/#memory/g' $tfile
fi
;;
2)
# kernel
if [ $kerneltweak ]
then
$busyfusion sed -i 's/#kernel/kernel #/g' $tfile
else
$busyfusion sed -i 's/kernel #/#kernel/g' $tfile
fi
;;
3)
# schedule
if [ $scheduletweak ]
then
$busyfusion sed -i 's/#schedule/schedule #/g' $tfile
else
$busyfusion sed -i 's/schedule #/#schedule/g' $tfile
fi
;;
4)
# zipsys
if [ $zipsystweak ]
then
$busyfusion sed -i 's/#zipsys/zipsys #/g' $tfile
else
$busyfusion sed -i 's/zipsys #/#zipsys/g' $tfile
fi
;;
5)
# zipdat
if [ $zipdattweak ]
then
$busyfusion sed -i 's/#zipdat/zipdat #/g' $tfile
else
$busyfusion sed -i 's/zipdat #/#zipdat/g' $tfile
fi
;;
6)
# filesystem
if [ $filesystweak ]
then
$busyfusion sed -i 's/#filesys/filesys #/g' $tfile
else
$busyfusion sed -i 's/filesys #/#filesys/g' $tfile
fi
;;
7)
# dropcache
if [ $dropcachetweak ]
then
$busyfusion sed -i 's/#dropcache/dropcache #/g' $tfile
else
$busyfusion sed -i 's/dropcache #/#dropcache/g' $tfile
fi
;;
8)
# contacts
if [ $contactstweak ]
then
$busyfusion sed -i 's/#contacts/contacts #/g' $tfile
else
$busyfusion sed -i 's/contacts #/#contacts/g' $tfile
fi
;;
9)
# odexsys
if [ $odexsystweak ]
then
$busyfusion sed -i 's/#odexsys/odexsys #/g' $tfile
else
$busyfusion sed -i 's/odexsys #/#odexsys/g' $tfile
fi
;;
10)
# odexdat
if [ $odexdattweak ]
then
$busyfusion sed -i 's/#odexdat/odexdat #/g' $tfile
else
$busyfusion sed -i 's/odexdat #/#odexdat/g' $tfile
fi
;;
11)
# delayed
if [ $delayedtweak ]
then
$busyfusion sed -i 's/#delayed/delayed #/g' $tfile
else
$busyfusion sed -i 's/delayed #/#delayed/g' $tfile
fi
;;
12)
# logger
if [ $loggertweak ]
then
$busyfusion sed -i 's/#logger/logger #/g' $tfile
else
$busyfusion sed -i 's/logger #/#logger/g' $tfile
fi
;;
13)

if [ ! -e /system/init.d/99SuperCharger ]
then

# memory
if [ $memorytweak ]
then
$busyfusion sed -i 's/#memory/memory #/g' $tfile
fi
# kernel
if [ $kerneltweak ]
then
$busyfusion sed -i 's/#kernel/kernel #/g' $tfile
fi

fi
# schedule
if [ $scheduletweak ]
then
$busyfusion sed -i 's/#schedule/schedule #/g' $tfile
fi
;;
14)
# zipsys
if [ $zipsystweak ]
then
$busyfusion sed -i 's/#zipsys/zipsys #/g' $tfile
fi
# zipdat
if [ $zipdattweak ]
then
$busyfusion sed -i 's/#zipdat/zipdat #/g' $tfile
fi
# filesystem
if [ $filesystweak ]
then
$busyfusion sed -i 's/#filesys/filesys #/g' $tfile
fi
# dropcache
if [ $dropcachetweak ]
then
$busyfusion sed -i 's/#dropcache/dropcache #/g' $tfile
fi
# contacts
if [ $contactstweak ]
then
$busyfusion sed -i 's/#contacts/contacts #/g' $tfile
fi
;;
16)
# adbwifi
if [ $adbwifitweak ]
then
$busyfusion sed -i 's/#adbwifi/adbwifi #/g' $tfile
else
$busyfusion sed -i 's/adbwifi #/#adbwifi/g' $tfile
setprop service.adb.tcp.port -1
stop adbd
start adbd
fi
;;
15)
# multimount
if [ $multimounttweak ]
then
$busyfusion sed -i 's/#multimount/multimount #/g' $tfile
else
$busyfusion sed -i 's/multimount #/#multimount/g' $tfile
fi
;;
44)
# nonsense
if [ $sensetweak ]
then
$busyfusion sed -i 's/#nonsense/nonsense #/g' $tfile
else
$busyfusion sed -i 's/nonsense #/#nonsense/g' $tfile
fi
;;
55)
if [ $cpufreqstweak ]
then
$busyfusion sed -i 's/#cpufreqs/cpufreqs #/g' $tfile
else
$busyfusion sed -i 's/cpufreqs #/#cpufreqs/g' $tfile
fi
;;
88)
echo "Please enter command filename: "
echo -n "/sdcard/"
read command
echo "" >> $tfile
cat $tfile /sdcard/$command > temp
cp temp $tfile
echo
echo "Custom "$command" imported. Process complete"
echo "Adding duplicates causes looping when executed"
echo "Return to Main before adding "$command" again"
echo
;;
99)
defaulttweak
echo '#memory' >> $tfile
echo '#kernel' >> $tfile
echo '#schedule' >> $tfile
echo '#odexsys' >> $tfile
echo '#odexdat' >> $tfile
echo '#zipsys' >> $tfile
echo '#zipdat' >> $tfile
echo '#filesys' >> $tfile
echo '#cpufreqs' >> $tfile
echo '#dropcache' >> $tfile
echo '#contacts' >> $tfile
echo '#adbwifi' >> $tfile
echo '#nonsense' >> $tfile
echo '#delayed' >> $tfile
echo '#logger' >> $tfile
echo
echo "Selections reset. All tweaks disabled"
;;
*)
chmod 555 $tfile
echo
echo "All set! Reboot to experience changes."
sh /data/data/com.fusion.tbolt/files/speedtweak.sh
exit
$busyfusion clear
;;
esac

echo
echo -n "Please hit Enter to continue:"
read key
done

}

line=================================================

# System Enhancements

blockads () {

OLDHOSTSMD5=`md5sum /system/etc/hosts | $busyfusion cut -b -32`

echo "Fetching host file via hostname"
cd /data/local/tmp
$wgetfusion -O hosts http://dl.dropbox.com/u/24904191/hosts

if [ ! -s hosts ]; then
echo "The busybox version of wget on your system does not work correctly with
hostnames. Trying workaround with latest known IP to the hostname..."
$wgetfusion -O hosts http://50.17.213.175/u/24904191/hosts
fi

if [ -s hosts ]; then
NEWHOSTSMD5=`md5sum hosts | $busyfusion cut -b -32`

if [ "$NEWHOSTSMD5" == "$OLDHOSTSMD5" ]; then
$busyfusion rm hosts
echo "host file is already up to date, exiting..."
$busyfusion sync
else
cd /
$busyfusion mount -o remount,rw -t ext3 /dev/block/mtdblock5 /system
echo "backing up old host file and updating"
$busyfusion mv /system/etc/hosts /system/etc/hosts.bak
$busyfusion cp /data/local/tmp/hosts /system/etc/hosts
OLDHOSTSMD5=`md5sum /system/etc/hosts | $busyfusion cut -b -32`

if [ "$NEWHOSTSMD5" != "$OLDHOSTSMD5" ]; then
echo "Host file could not be updated (could not be moved). Aborting..."
$busyfusion mount -o remount,ro -t ext3 /dev/block/mtdblock5 /system
$busyfusion sync
else

chown root /system/etc/hosts
chmod 644 /system/etc/hosts

echo "Cleaning up files..."
$busyfusion rm hosts
fi
fi
echo "Ad blocking has been activated / updated"
fi

}

boostdata () {

#featureexist=`$busyfusion grep -m 1 -F "ro.ril.hsxpa" /system/build.prop`
$busyfusion clear
echo
echo "3G Boosting Options"
echo "---------------------"
echo "1) Add 3G Boost Values"
echo "2) Fix Boost Connection"
echo "3) Remove Boost Values"
echo
echo "0) Exit Menu"
echo
echo "---"
echo -n "Please enter a number: "
read option
case $option in
1)
$busyfusion sed -i /Enhanced\ 3G\ Radio\ Modification/d /system/build.prop
$busyfusion sed -i /ro.ril.hsxpa/d /system/build.prop
$busyfusion sed -i /ro.ril.gprsclass/d /system/build.prop
$busyfusion sed -i /ro.ril.hep/d /system/build.prop
$busyfusion sed -i /ro.ril.enable.dtm/d /system/build.prop
$busyfusion sed -i /ro.ril.hsdpa.category/d /system/build.prop
$busyfusion sed -i /ro.ril.enable.a53/d /system/build.prop
$busyfusion sed -i /ro.ril.enable.a52/d /system/build.prop
$busyfusion sed -i /ro.ril.enable.3g.prefix/d /system/build.prop
$busyfusion sed -i /ro.ril.htcmaskw1.bitmask/d /system/build.prop
$busyfusion sed -i /ro.ril.htcmaskw1/d /system/build.prop
$busyfusion sed -i /ro.ril.hsupa.category/d /system/build.prop
$busyfusion sed -i /ro.ril.def.agps.mode/d /system/build.prop
$busyfusion sed -i /ro.ril.def.agps.feature/d /system/build.prop
$busyfusion sed -i /ro.ril.enable.sdr/d /system/build.prop
$busyfusion sed -i /ro.ril.enable.gea3/d /system/build.prop
$busyfusion sed -i /ro.ril.enable.fd.plmn.prefix/d /system/build.prop
$busyfusion sed -i /ro.ril.disable.power.collapse/d /system/build.prop
$busyfusion sed -i /Fix\ Connection/d /system/build.prop

$busyfusion cp /system/build.prop /system/build.prop.3gb

$busyfusion sed -i 1'i\# Enhanced 3G Radio Modification' /system/build.prop
$busyfusion sed -i 2'i\ro.ril.hsxpa=2' /system/build.prop
$busyfusion sed -i 3'i\ro.ril.gprsclass=32' /system/build.prop
$busyfusion sed -i 4'i\ro.ril.hep=1' /system/build.prop
$busyfusion sed -i 5'i\ro.ril.hsdpa.category=28' /system/build.prop
$busyfusion sed -i 6'i\ro.ril.enable.3g.prefix=1' /system/build.prop
$busyfusion sed -i 7'i\ro.ril.htcmaskw1.bitmask=4294967295' /system/build.prop
$busyfusion sed -i 8'i\ro.ril.htcmaskw1=268449905' /system/build.prop
$busyfusion sed -i 9'i\ro.ril.hsupa.category=9' /system/build.prop
$busyfusion sed -i 10'i\ro.ril.def.agps.mode=2' /system/build.prop
$busyfusion sed -i 11'i\ro.ril.def.agps.feature=1' /system/build.prop
$busyfusion sed -i 12'i\ro.ril.enable.sdr=1' /system/build.prop
$busyfusion sed -i 13'i\ro.ril.enable.gea3=1' /system/build.prop
$busyfusion sed -i 14'i\ro.ril.enable.fd.plmn.prefix=23402,23410,23411' /system/build.prop
$busyfusion sed -i 15'i\ro.ril.disable.power.collapse=0' /system/build.prop
$busyfusion sed -i 16'i\ro.ril.enable.a52=0' /system/build.prop
$busyfusion sed -i 17'i\ro.ril.enable.a53=1' /system/build.prop
$busyfusion sed -i 18'i\ro.ril.enable.dtm=1' /system/build.prop

echo
echo '3G Boost added. Reboot for changes'
;;
2)
$busyfusion sed -i 's/ro.ril.enable.a53.*=.*m/ro.ril.enable.a53=0/g' /system/build.prop
$busyfusion sed -i 's/ro.ril.enable.dtm.*=.*m/ro.ril.enable.dtm=0/g' /system/build.prop

echo
echo '3G Boost edited. Reboot for changes'
;;
3)
$busyfusion sed -i /Enhanced\ 3G\ Radio\ Modification/d /system/build.prop
$busyfusion sed -i /ro.ril.hsxpa/d /system/build.prop
$busyfusion sed -i /ro.ril.gprsclass/d /system/build.prop
$busyfusion sed -i /ro.ril.hep/d /system/build.prop
$busyfusion sed -i /ro.ril.enable.dtm/d /system/build.prop
$busyfusion sed -i /ro.ril.hsdpa.category/d /system/build.prop
$busyfusion sed -i /ro.ril.enable.a53/d /system/build.prop
$busyfusion sed -i /ro.ril.enable.a52/d /system/build.prop
$busyfusion sed -i /ro.ril.enable.3g.prefix/d /system/build.prop
$busyfusion sed -i /ro.ril.htcmaskw1.bitmask/d /system/build.prop
$busyfusion sed -i /ro.ril.htcmaskw1/d /system/build.prop
$busyfusion sed -i /ro.ril.hsupa.category/d /system/build.prop
$busyfusion sed -i /ro.ril.def.agps.mode/d /system/build.prop
$busyfusion sed -i /ro.ril.def.agps.feature/d /system/build.prop
$busyfusion sed -i /ro.ril.enable.sdr/d /system/build.prop
$busyfusion sed -i /ro.ril.enable.gea3/d /system/build.prop
$busyfusion sed -i /ro.ril.enable.fd.plmn.prefix/d /system/build.prop
$busyfusion sed -i /ro.ril.disable.power.collapse/d /system/build.prop
$busyfusion sed -i /Fix\ Connection/d /system/build.prop
if [ -e /system/build.prop.3gb ]
then
$busyfusion rm -rf /system/build.prop.3gb
fi
echo
echo '3G Boost removed. Reboot for changes'
;;
*)
;;
esac

}

# Binary Maintainance

binaryinstall() {

while [ 1 ]; do
$busyfusion clear
echo
echo "Binary Install Options"
echo "----------------------"
echo "1) Update Busybox"
if [ ! -e /system/xbin/bash ]
then
echo "2) Install Bash Support"
fi
if [ ! -e /system/bin/zipalign ]
then
echo "3) Install ZipAlign Support"
fi
if [ ! -e /system/xbin/dexopt-wrapper ]
then
echo "4) Install DexOpt Support"
fi
if [ ! -e /system/xbin/wget ]
then
echo "5) Install Updated wGet"
elif [ -h /system/xbin/wget ]
then
echo "5) Install Updated wGet"
elif [ $wgetcheck -lt 24000 ]
then
echo "5) Install Updated wGet"
fi
if [ ! -e /system/bin/flash_image ]
then
echo "6) Install flash_image"
fi
echo
echo "0) Exit Menu"
echo
echo "---"
echo -n "Please enter a number: "
read binaryoption
case $binaryoption in
1)
cd /sdcard/ScriptFusion
$wgetfusion $server/BusyboxBin/
cd /
$viewitem file:///sdcard/ScriptFusion/index.html
echo
cd /system/xbin
cp busybox busybox.bak
$wgetfusion -T 5 -N $server/ScriptFusion/binaryfiles/busybox
chown 0:0 busybox
chmod 4755 busybox
cd /
integrity=`$busyfusion stat -c %s /system/xbin/busybox`
if [ $integrity -lt 1 ]
then
echo
echo "Update could not be completed. Try later"
$busyfusion mv -f /system/xbin/busybox.bak /system/xbin/busybox
chmod 4755 busybox
else
$busyfusion clear
echo
echo "Busybox Install Options"
echo "-----------------------"
echo "1) Install Symlinks"
echo "2) Binary Update"
echo
echo "---"
echo -n "Please enter a number: "
read busyboxselect
case $busyboxselect in
1)
$busyfusion mv -f /system/xbin/wget /system/xbin/wget.bak
$busyfusion cp -a /system/xbin/su /system/xbin/su.bak
/system/xbin/busybox --install -s /system/xbin
$busyfusion rm -rf /system/xbin/su
$busyfusion mv -f /system/xbin/su.bak /system/xbin/su
$busyfusion rm -rf /system/xbin/wget
$busyfusion mv -f /system/xbin/wget.bak /system/xbin/wget
echo
echo "Busybox binary installed. Happy scripting!"
;;
*)
echo
echo "Busybox binary updated. Happy scripting!"
;;
esac
fi
$busyfusion rm -rf /system/xbin/busybox.bak
;;
2)
echo
$wgetfusion -O /system/xbin/bash $server/Ext2buntu/bash
chmod 755 /system/xbin/bash
integrity=`$busyfusion stat -c %s /system/xbin/bash`
if [ $integrity -lt 1 ]
then
echo
echo "Update could not be completed. Try later"
$busyfusion rm -rf /system/xbin/bash
else
echo
echo "Bash binary installed. Happy scripting!"
fi
;;
3)
echo
$wgetfusion -O /system/bin/zipalign $server/ScriptFusion/binaryfiles/zipalign
chmod 755 /system/bin/zipalign
integrity=`$busyfusion stat -c %s /system/bin/zipalign`
if [ $integrity -lt 1 ]
then
echo
echo "Update could not be completed. Try later"
$busyfusion rm -rf /system/bin/zipalign
else
echo
echo "ZipAlign binary installed. Happy scripting!"
fi
;;
4)
echo
$wgetfusion -O /system/xbin/dexopt-wrapper $server/ScriptFusion/binaryfiles/dexopt-wrapper
chmod 777 /system/xbin/dexopt-wrapper
integrity=`$busyfusion stat -c %s /system/xbin/dexopt-wrapper`
if [ $integrity -lt 1 ]
then
echo
echo "Update could not be completed. Try later"
$busyfusion rm -rf /system/xbin/dexopt-wrapper
else
echo
echo "DexOpt binary installed. Happy scripting!"
fi
;;
5)
echo
$busyfusion rm -rf /system/xbin/wget
$wgetfusion -O /system/xbin/wget $server/ScriptFusion/binaryfiles/wget
chmod 755 /system/xbin/wget
integrity=`$busyfusion stat -c %s /system/xbin/wget`
if [ $integrity -lt 1 ]
then
echo
echo "Update could not be completed. Try later"
$busyfusion rm -rf /system/xbin/wget
else
echo
echo "wGet binary installed. Happy scripting!"
fi
;;
6)
$wgetfusion -O /system/bin/flash_image $server/ScriptFusion/binaryfiles/flash_image
chmod 755 /system/bin/flash_image
integrity=`$busyfusion stat -c %s /system/bin/flash_image`
if [ $integrity -lt 1 ]
then
echo
echo "Update could not be completed. Try later"
$busyfusion rm -rf /system/bin/flash_image
else
echo
echo "Image binary installed. Happy scripting!"
fi
;;
*)
sleep 1
sh /data/data/com.fusion.tbolt/files/speedtweak.sh
exit
$busyfusion clear
;;
esac
echo
echo -n "Please hit Enter to continue:"
read key
done

}

systemoptions() {

#!/system/bin/sh<<EOF

while [ 1 ]; do
$busyfusion clear
adstatus=`$busyfusion cat /system/etc/hosts | $busyfusion awk '{ print $2 }'`
keyfilemecha="/system/usr/keylayout/mecha-keypad.kl"
keyfilespade="/system/usr/keylayout/spade-keypad.kl"
echo
echo "System Editing Options"
echo "---------------------"
if [ -e /system/xbin/dexopt-wrapper ]; then
echo "1) Java Odex Optimization"
else
echo "Install DexOpt Support (1)"
fi
echo "2) Change Screen Density"
echo "3) Proximity Sensor Settings"
if [ -e $keyfilemecha ]
then
keyfile = "/system/usr/keylayout/mecha-keypad.kl"
echo "4) Wake on Volume Toggles"
elif [ -e $keyfilespade ]
then
keyfile = "/system/usr/keylayout/spade-keypad.kl"
echo "4) Wake on Volume Toggles"
fi
echo
echo "5) System App Options"
echo "6) App Package Manager"
echo
if [ "$adstatus" == 'updated:' ]
then
echo "7) Turn Ad Blocking Off"
echo "8) Update Ad Block List"
else
echo "7) Turn Ad Blocking On"
fi
echo "9) Display Battery Stats"
echo
echo "10) ADB Wireless Options"
echo "11) Dual Mount SDcard"
echo "12) 3G Connection Boost"
echo "13) Image Flash Utility"
echo "14) Vibration Intensity"
echo
echo 'x) Discard Backup Files'
echo "0) Exit Menu"
echo
echo "---"
echo -n "Please enter a number: "
read option
case $option in
1)
$busyfusion clear
echo
echo "Odex Optimize Selection"
echo "-----------------------"
echo "1) System Apps"
echo "2) User Apps"
echo "3) All Apps"
echo
echo "---"
echo -n "Please enter a number: "
read odexselection
case $odexselection in
1)
echo
for i in /system/app/*.apk
do
odex=`echo $i | sed -e 's/.apk/.odex/g'`
if [ ! -f $odex ] ; then
# $busyfusion rm -rf /data/dalvik-cache/system@app@*.dex
echo "dexopt-wrapper $i $odex"
dexopt-wrapper $i $odex
fi
done
echo
echo "Operation complete. Please Reboot."
echo
sleep 1
;;
2)
echo
$busyfusion rm -rf /data/app/*.odex
for i in /data/app/*.apk
do
odex=`echo $i | sed -e 's/.apk/.odex/g'`
echo "dexopt-wrapper $i $odex"
dexopt-wrapper $i $odex
done

$busyfusion rm -rf /data/app-private/*.odex

for i in /data/app-private/*.apk
do
odex=`echo $i | sed -e 's/.apk/.odex/g'`
echo "dexopt-wrapper $i $odex"
dexopt-wrapper $i $odex
done
echo
echo "Please clear dalvik-cache and reboot"
echo
;;
3)
echo
for i in /system/app/*.apk
do
odex=`echo $i | sed -e 's/.apk/.odex/g'`
if [ ! -f $odex ] ; then
echo "dexopt-wrapper $i $odex"
dexopt-wrapper $i $odex
cachefile=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/system\/app\///' | $busyfusion sed 's/\.apk//'`
$busyfusion rm -rf /data/dalvik-cache/*$cachefile*
fi
done

$busyfusion rm -rf /data/app/*.odex

for i in /data/app/*.apk
do
odex=`echo $i | sed -e 's/.apk/.odex/g'`
echo "dexopt-wrapper $i $odex"
dexopt-wrapper $i $odex
#cachefile=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/data\/app\///' | $busyfusion sed 's/\.apk//'`
#$busyfusion rm -rf /data/dalvik-cache/*$cachefile*
done

$busyfusion rm -rf /data/app-private/*.odex

for i in /data/app-private/*.apk
do
odex=`echo $i | sed -e 's/.apk/.odex/g'`
echo "dexopt-wrapper $i $odex"
dexopt-wrapper $i $odex
#cachefile=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/data\/app-private\///' | $busyfusion sed 's/\.apk//'`
#$busyfusion rm -rf /data/dalvik-cache/*$cachefile*
done
echo
echo "Please clear dalvik-cache and reboot"
echo
;;
*)
;;
esac
;;
2)
$busyfusion clear
currentdensity=`$busyfusion grep -m 1 -F 'ro.sf.lcd_density' /system/build.prop | $busyfusion sed 's/ro.sf.lcd_density=//'`
echo
echo "Screen Density Editor"
echo "---------------------"
echo "Current Screen Density: $currentdensity"
echo "Recommended 160, 176, 200"
echo
echo -n "Please enter new screen density : "
read custdensity
if [ "$custdensity" == "" ]
then
echo
echo "Screen density set to $currentdensity"
else
$busyfusion cp /system/build.prop /system/build.prop.sdb
denseuser="s/ro.sf.lcd_density.*=.*/ro.sf.lcd_density=$custdensity/g"
$busyfusion sed -i $denseuser /system/build.prop
echo
echo "Screen density set to $custdensity"
fi
;;
3)
featureexist=`$busyfusion grep -m 1 -F "gsm.proximity.enable" /system/build.prop`
disabledproximity=`$busyfusion grep -m 1 -F "gsm.proximity.enable=true" /system/build.prop`

$busyfusion clear
echo
echo "Proximity Sensor Options"
echo "------------------------"
if [ $featureexist ]
then
echo $featureexist
echo
if [ $disabledproximity ]
then
echo "1) Disable Proximity Sensor"
else
echo "2) Enable Proximity Sensor"
fi
else
echo
echo "1) Disable Proximity Sensor"
fi
echo
echo "0: Exit Menu"
echo
echo "---"
echo -n "Please choose an option: "
read proximityoption
case $proximityoption in
1)
if [ $featureexist ]
then
$busyfusion sed -i 's/gsm.proximity.enable.*=.*m/gsm.proximity.enable=false/g' /system/build.prop
echo
echo "Proximity sensor disabled"
else
echo 'gsm.proximity.enable=false' >> /system/build.prop
echo
echo "Proximity sensor disabled"
fi
;;
2)
$busyfusion sed -i 's/gsm.proximity.enable.*=.*m/gsm.proximity.enable=true/g' /system/build.prop
echo
echo "Proximity sensor enabled"
;;
*)
;;
esac
;;
4)
volumeup=`$busyfusion grep -m 1 -F "VOLUME_UP" $keyfile | $busyfusion awk '{ print $4 }'`
volumedown=`$busyfusion grep -m 1 -F "VOLUME_DOWN" $keyfile | $busyfusion awk '{ print $4 }'`
$busyfusion clear
echo
echo "Volume Wake Options"
echo "------------------"
if [ $volumeup ]
then
echo "1) Disable Volume Up Wake"
else
echo "2) Enable Volume Up Wake"
fi
if [ $volumedown ]
then
echo "3) Disable Volume Down Wake"
else
echo "4) Enable Volume Down Wake"
fi
echo
echo "0: Exit Menu"
echo
echo "---"
echo -n "Please choose an option: "
read volumeoption
case $volumeoption in
1)
$busyfusion sed -i 's/VOLUME_UP         WAKE/VOLUME_UP/g' $keyfile
echo
echo "Wake on volume up disabled"
;;
2)
$busyfusion sed -i 's/VOLUME_UP/VOLUME_UP         WAKE/g' $keyfile
echo
echo "Wake on volume up enabled"
;;
3)
$busyfusion sed -i 's/VOLUME_DOWN       WAKE/VOLUME_DOWN/g' $keyfile
echo
echo "Wake on volume down disabled"
;;
4)
$busyfusion sed -i 's/VOLUME_DOWN/VOLUME_DOWN       WAKE/g' $keyfile
echo
echo "Wake on volume down enabled"
;;
*)
;;
esac
;;
5)
$busyfusion clear
echo
echo "System Apps Options"
echo "--------------------"
echo "1) Remove System App"
echo "2) Include System App"
echo
echo "0: Exit Menu"
echo
echo "---"
echo -n "Please choose an option: "
read sysapps
case $sysapps in
1)
$busyfusion clear
echo
echo "Select System Apps"
echo "-------------------"
#$busyfusion find /system/app/ -maxdepth 1 -type f
n=1
for i in /system/app/*.apk
do
friendlyname=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/system\/app\///'`
htcsystem=`$busyfusion grep -oFe 'HTC' $friendlyname`
googlesystem=`$busyfusion grep -oFe 'Google' $friendlyname`
if [ $htcsystem ]
then
echo $n': '$friendlyname' - HTC App'
elif [ $googlesystem ]
then
echo $n': '$friendlyname' - Google App'
else
echo $n': '$friendlyname
fi
n=`$busyfusion expr $n + 1`
done
echo
echo "---"
echo -n "Please choose an application: "
read sysappsadd
if [ $sysappsadd ]
then
for i in /system/app/*.apk
do
if [ $n == $sysappsadd ]
then
echo
$busyfusion rm -rf $i
cachefile=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/system\/app\///' | $busyfusion sed 's/\.apk//'`
$busyfusion rm -rf /data/dalvik-cache/*$cachefile*
echo `$busyfusion stat -c %n $i | $busyfusion sed 's/\/system\/app\///'`" has been removed"
fi
n=`$busyfusion expr $n + 1`
done
fi
;;
2)
$busyfusion clear
if [ -e /sdcard/*.apk ]
then
echo
echo "Select System Apps"
echo "-------------------"
n=1
for i in /sdcard/*.apk
do
echo $n": "`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\///'`
n=`$busyfusion expr $n + 1`
done
echo
echo "---"
echo -n "Please choose an application: "
read sysappsadd
if [ $sysappsadd ]
then
n=1
for i in /sdcard/*.apk
do
if [ $n == $sysappsadd ]
then
echo
sdcardapp=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\///'`
cp $sdcardapp /system/app/
chmod 644 /system/app/
echo $sdcardapp" moved to /system/app/"
fi
n=`$busyfusion expr $n + 1`
done
fi
else
echo
echo 'Please move desired apps to /sdcard/'
fi
;;
*)

;;
esac
;;
6)
$busyfusion clear
echo
echo "Package Manager Menu"
echo "--------------------"
echo "1) Install Packages"
echo "2) Remove Packages"
echo
echo "0: Exit Menu"
echo
echo "---"
echo -n "Please choose an option: "
read sysapps
case $sysapps in
1)
$busyfusion clear
if [ -e /sdcard/*.apk ]
then
echo
echo "Installable Apps"
echo "-----------------"
n=1
for i in /sdcard/*.apk
do
echo $n": "`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\///'`
n=`$busyfusion expr $n + 1`
done
echo
echo "---"
echo -n "Please choose an application: "
read sysappsadd
if [ $sysappsadd ]
then
n=1
for i in /sdcard/*.apk
do
if [ $n == $sysappsadd ]
then
echo
sdcardapp=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\///'`
echo "Install Location Menu"
echo "--------------------"
echo "1) Install Internal"
echo "2) Install External"
echo
echo "---"
echo -n "Please choose an option: "
read installplace
if [ "$installplace" == "2" ]; then
installext'-s'
else
installext='-f'
fi
pm install $sdcardapp $installext
fi
n=`$busyfusion expr $n + 1`
done
fi
else
echo
echo 'Please move desired apps to /sdcard/'
fi
;;
2)
$busyfusion clear
echo -n "Enter Partial App Name: "
read partialname
pmcheck=`pm list packages | $busyfusion grep $partialname | $busyfusion sed 's/package\://'`
if [ $pmcheck ]; then
pm uninstall $pmcheck
fi
;;
*)
;;
esac
;;
7)
if [ "$adstatus" == 'updated:' ]
then
echo '127.0.0.1 localhost' > /system/etc/hosts
$busyfusion sync
echo "Ad blocking has been deactivated"
else
blockads
fi
;;
8)
blockads
;;
9)
$busyfusion clear
echo
dumpsys battery
;;
10)
$busyfusion clear
echo
echo "ADB Wireless Settings"
echo "---------------------"
echo "1) Activate Wireless Connect"
echo "2) Disable Wireless Connect"
echo
echo "0: Exit Menu"
echo
echo "---"
echo -n "Please choose an option: "
read wiredoption
case $wiredoption in
1)
setprop service.adb.tcp.port 5555
stop adbd
start adbd
echo
device_ip=`$busyfusion ifconfig eth0 | $busyfusion grep "inet addr" | $busyfusion awk -F: '{print $2}' | $busyfusion awk '{print $1}'`
echo 'Enter "adb connect '$device_ip':5555"'
;;
2)
setprop service.adb.tcp.port -1
stop adbd
start adbd
echo
echo "Wireless adb Disabled. USB Active"
;;
*)
;;
esac
;;
11)
availablemounts=`$busyfusion ls -x dev/block//vold | $busyfusion awk '{ print $3 }'`
echo $availablemounts > /sys/devices/platform/usb_mass_storage/lun0/file
echo
echo "SDcard Multiple Mount Enabled"
;;
12)
boostdata
;;
13)
modulefile() {

if [ -e /sdcard/*.ko ]
then
echo
echo "Available Modules"
echo "-----------------"
n=1
for i in /sdcard/*.ko
do
echo $n": "`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\///'`
n=`$busyfusion expr $n + 1`
done
echo
echo "---"
echo -n "Please choose a module: "
read sysappsadd
if [ $sysappsadd ]
then
n=1
for i in /sdcard/*.ko
do
if [ $n == $sysappsadd ]
then
echo
sdcardapp=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\///'`
cp $i /system/lib/modules/
fi
n=`$busyfusion expr $n + 1`
done
fi
else
echo
echo 'Please move desired module to /sdcard/'
fi

}

$busyfusion clear
echo
echo "Image Flash Options"
echo "--------------------"
echo "1) Flash New Boot Image"
echo "2) Flash Recovery Image"
echo "3) Add Extra Boot Modules"
echo
echo "0: Exit Menu"
echo
echo "---"
echo -n "Please choose an option: "
read sysapps
case $sysapps in
1)
$busyfusion clear
if [ -e /sdcard/*.img ]
then
echo
echo "Available Images"
echo "-----------------"
n=1
for i in /sdcard/*.img
do
echo $n": "`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\///'`
n=`$busyfusion expr $n + 1`
done
echo
echo "---"
echo -n "Please choose an image: "
read sysappsadd
if [ $sysappsadd ]
then
n=1
for i in /sdcard/*.img
do
if [ $n == $sysappsadd ]
then
echo
sdcardapp=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\///'`
$flashfusion boot $i
modulefile
fi
n=`$busyfusion expr $n + 1`
done
fi
else
echo
echo 'Please move desired image to /sdcard/'
fi
;;
2)
$busyfusion clear
if [ -e /sdcard/*.img ]
then
echo
echo "Available Images"
echo "-----------------"
n=1
for i in /sdcard/*.img
do
echo $n": "`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\///'`
n=`$busyfusion expr $n + 1`
done
echo
echo "---"
echo -n "Please choose an image: "
read sysappsadd
if [ $sysappsadd ]
then
n=1
for i in /sdcard/*.img
do
if [ $n == $sysappsadd ]
then
echo
sdcardapp=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\///'`
$flashfusion recovery $i
fi
n=`$busyfusion expr $n + 1`
done
fi
else
echo
echo 'Please move desired image to /sdcard/'
fi
;;
3)
modulefile
;;
*)
;;
esac
;;
14)
echo "Please enter an intensity (ex.1000, 2000, 3000)"
read intensity
echo 'echo "'$intensity'" > /sys/devices/virtual/timed_output/vibrator/voltage_level' > $vfile
;;
x)
if [ -e /system/build.prop.bak ]
then
$busyfusion rm -rf /system/build.prop.bak
fi
if [ -e /system/build.prop.sfb ]
then
$busyfusion rm -rf /system/build.prop.sfb
fi
if [ -e /system/build.prop.sdb ]
then
$busyfusion rm -rf /system/build.prop.sdb
fi
if [ -e /system/build.prop.3gb ]
then
$busyfusion rm -rf /system/build.prop.3gb
fi

echo
echo 'All build.prop backups removed'
;;
*)
sleep 1
sh /data/data/com.fusion.tbolt/files/speedtweak.sh
exit
$busyfusion clear
;;
esac
echo
echo -n "Please hit Enter to continue:"
read key
done

EOF

}

fixedpermission() {

$busyfusion clear
echo
# Warning: if you want to run this script in cm-recovery change the above to #!/sbin/sh
#
# fix_permissions - fixes permissions on Android data directories after upgrade
# shade@chemlab.org
#
# original concept: http://blog.elsdoerfer.name/2009/05/25/android-fix-package-uid-mismatches/
# implementation by: Cyanogen
# improved by: ankn, smeat, thenefield, farmatito, rikupw, Kastro
#
# v1.1-v1.31r3 - many improvements and concepts from XDA developers.
# v1.34 through v2.00 -  A lot of frustration [by Kastro]
# v2.01	- Completely rewrote the script for SPEED, thanks for the input farmatito
#         /data/data depth recursion is tweaked;
#         fixed single mode;
#         functions created for modularity;
#         logging can be disabled via CLI for more speed;
#         runtime computation added to end (Runtime: mins secs);
#         progress (current # of total) added to screen;
#         fixed CLI argument parsing, now you can have more than one option!;
#         debug cli option;
#         verbosity can be disabled via CLI option for less noise;;
#         [by Kastro, (XDA: k4str0), twitter;mattcarver]
# v2.02 - ignore com.htc.resources.apk if it exists and minor code cleanups,
#         fix help text, implement simulated run (-s) [farmatito]
# v2.03 - fixed chown group ownership output [Kastro]
# v2.04 - replaced /system/sd with $SD_EXT_DIRECTORY [Firerat]
VERSION="2.04"

# Defaults
DEBUG=0 # Debug off by default
LOGGING=1 # Logging on by default
VERBOSE=1 # Verbose on by default

# Messages
UID_MSG="Changing user ownership for:"
GID_MSG="Changing group ownership for:"
PERM_MSG="Changing permissions for:"

# Programs needed
ECHO="$busyfusion echo"
GREP="$busyfusion grep"
EGREP="$busyfusion egrep"
CAT="$busyfusion cat"
CHOWN="$busyfusion chown"
CHMOD="$busyfusion chmod"
MOUNT="$busyfusion mount"
UMOUNT="$busyfusion umount"
CUT="$busyfusion cut"
FIND="$busyfusion find"
LS="$busyfusion ls"
TR="$busyfusion tr"
TEE="$busyfusion tee"
TEST="$busyfusion test"
SED="$busyfusion sed"
RM="$busyfusion rm"
WC="$busyfusion wc"
EXPR="$busyfusion expr"
DATE="$busyfusion date"

# Initialise vars
CODEPATH=""
LOCALUID=""
LOCALGID=""
PACKAGE=""
REMOVE=0
NOSYSTEM=0
ONLY_ONE=""
SIMULATE=0
SYSREMOUNT=0
SYSMOUNT=0
DATAMOUNT=0
SYSSDMOUNT=0
FP_STARTTIME=$( $DATE +"%m-%d-%Y %H:%M:%S" )
FP_STARTEPOCH=$( $DATE +%s )
if $TEST "$SD_EXT_DIRECTORY" = ""; then
#check for mount point, /system/sd included in tests for backward compatibility
for MP in /sd-ext /system/sd;do
if $TEST -d $MP; then
SD_EXT_DIRECTORY=$MP
break
fi
done
fi
fp_usage()
{
$ECHO "Usage $0 [OPTIONS] [APK_PATH]"
$ECHO "      -d         turn on debug"
$ECHO "      -f         fix only package APK_PATH"
$ECHO "      -l         disable logging for this run (faster)"
$ECHO "      -r         remove stale data directories"
$ECHO "                 of uninstalled packages while fixing permissions"
$ECHO "      -s         simulate only"
$ECHO "      -u         check only non-system directories"
$ECHO "      -v         disable verbosity for this run (less output)"
$ECHO "      -V         print version"
$ECHO "      -h         this help"
}

fp_parseargs()
{
# Parse options
while $TEST $# -ne 0; do
case "$1" in
-d)
DEBUG=1
;;
-f)
if $TEST $# -lt 2; then
$ECHO "$0: missing argument for option $1"
exit 1
else
if $TEST $( $ECHO $2 | $CUT -c1 ) != "-"; then
ONLY_ONE=$2
shift;
else
$ECHO "$0: missing argument for option $1"
exit 1
fi
fi
;;
-r)
REMOVE=1
;;
-s)
SIMULATE=1
;;
-l)
if $TEST $LOGGING -eq 0; then
LOGGING=1
else
LOGGING=0
fi
;;
-v)
if $TEST $VERBOSE -eq 0; then
VERBOSE=1
else
VERBOSE=0
fi
;;
-u)
NOSYSTEM=1
;;
-V)
$ECHO "$0 $VERSION"
exit 0
;;
-h)
fp_usage
exit 0
;;
-*)
$ECHO "$0: unknown option $1"
$ECHO
fp_usage
exit 1
;;
esac
shift;
done
}

fp_print()
{
MSG=$@
if $TEST $LOGGING -eq 1; then
$ECHO $MSG | $TEE -a $LOG_FILE
else
$ECHO $MSG
fi
}

fp_start()
{
if $TEST $SIMULATE -eq 0 ; then
if $TEST $( $GREP -c " /system " "/proc/mounts" ) -ne 0; then
DEVICE=$( $GREP " /system " "/proc/mounts" | $CUT -d ' ' -f1 )
if $TEST $DEBUG -eq 1; then
fp_print "/system mounted on $DEVICE"
fi
if $TEST $( $GREP " /system " "/proc/mounts" | $GREP -c " ro " ) -ne 0; then
$MOUNT -o remount,rw $DEVICE /system
SYSREMOUNT=1
fi
else
$MOUNT /system > /dev/null 2>&1
SYSMOUNT=1
fi

if $TEST $( $GREP -c " /data " "/proc/mounts" ) -eq 0; then
$MOUNT /data > /dev/null 2>&1
DATAMOUNT=1
fi

if $TEST -e /dev/block/mmcblk0p2 && $TEST $( $GREP -c " $SD_EXT_DIRECTORY " "/proc/mounts" ) -eq 0; then
$MOUNT $SD_EXT_DIRECTORY > /dev/null 2>&1
SYSSDMOUNT=1
fi
fi
if $TEST $( $MOUNT | $GREP -c /sdcard ) -eq 0; then
LOG_FILE="/data/fix_permissions.log"
else
LOG_FILE="/sdcard/fix_permissions.log"
fi
if $TEST ! -e "$LOG_FILE"; then
> $LOG_FILE
fi

fp_print "$0 $VERSION started at $FP_STARTTIME"
}

fp_chown_uid()
{
FP_OLDUID=$1
FP_UID=$2
FP_FILE=$3

#if user ownership does not equal then change them
if $TEST "$FP_OLDUID" != "$FP_UID"; then
if $TEST $VERBOSE -ne 0; then
fp_print "$UID_MSG $FP_FILE from '$FP_OLDUID' to '$FP_UID'"
fi
if $TEST $SIMULATE -eq 0; then
$CHOWN $FP_UID "$FP_FILE"
fi
fi
}

fp_chown_gid()
{
FP_OLDGID=$1
FP_GID=$2
FP_FILE=$3

#if group ownership does not equal then change them
if $TEST "$FP_OLDGID" != "$FP_GID"; then
if $TEST $VERBOSE -ne 0; then
fp_print "$GID_MSG $FP_FILE from '$FP_OLDGID' to '$FP_GID'"
fi
if $TEST $SIMULATE -eq 0; then
$CHOWN :$FP_GID "$FP_FILE"
fi
fi
}

fp_chmod()
{
FP_OLDPER=$1
FP_OLDPER=$( $ECHO $FP_OLDPER | cut -c2-10 )
FP_PERSTR=$2
FP_PERNUM=$3
FP_FILE=$4

#if the permissions are not equal
if $TEST "$FP_OLDPER" != "$FP_PERSTR"; then
if $TEST $VERBOSE -ne 0; then
fp_print "$PERM_MSG $FP_FILE from '$FP_OLDPER' to '$FP_PERSTR' ($FP_PERNUM)"
fi
#change the permissions
if $TEST $SIMULATE -eq 0; then
$CHMOD $FP_PERNUM "$FP_FILE"
fi
fi
}

fp_all()
{
FP_NUMS=$( $CAT /data/system/packages.xml | $EGREP "^<package.*serId" | $GREP -v framework-res.apk | $GREP -v com.htc.resources.apk | $WC -l )
I=0
$CAT /data/system/packages.xml | $EGREP "^<package.*serId" | $GREP -v framework-res.apk | $GREP -v com.htc.resources.apk | while read all_line; do
I=$( $EXPR $I + 1 )
fp_package "$all_line" $I $FP_NUMS
done
}

fp_single()
{
FP_SFOUND=$( $CAT /data/system/packages.xml | $EGREP "^<package.*serId" | $GREP -v framework-res.apk | $GREP -v com.htc.resources.apk | $GREP -i $ONLY_ONE | wc -l )
if $TEST $FP_SFOUND -gt 1; then
fp_print "Cannot perform single operation on $FP_SFOUND matched package(s)."
elif $TEST $FP_SFOUND = "" -o $FP_SFOUND -eq 0; then
fp_print "Could not find the package you specified in the packages.xml file."
else
FP_SPKG=$( $CAT /data/system/packages.xml | $EGREP "^<package.*serId" | $GREP -v framework-res.apk | $GREP -v com.htc.resources.apk | $GREP -i $ONLY_ONE )
fp_package "${FP_SPKG}" 1 1
fi
}

fp_package()
{
pkgline=$1
curnum=$2
endnum=$3
CODEPATH=$( $ECHO $pkgline | $SED 's%.* codePath="\(.*\)".*%\1%' |  $CUT -d '"' -f1 )
PACKAGE=$( $ECHO $pkgline | $SED 's%.* name="\(.*\)".*%\1%' | $CUT -d '"' -f1 )
LOCALUID=$( $ECHO $pkgline | $SED 's%.*serId="\(.*\)".*%\1%' |  $CUT -d '"' -f1 )
LOCALGID=$LOCALUID
APPDIR=$( $ECHO $CODEPATH | $SED 's%^\(.*\)/.*%\1%' )
APK=$( $ECHO $CODEPATH | $SED 's%^.*/\(.*\..*\)$%\1%' )

#debug
if $TEST $DEBUG -eq 1; then
fp_print "CODEPATH: $CODEPATH APPDIR: $APPDIR APK:$APK UID/GID:$LOCALUID:$LOCALGID"
fi

#check for existence of apk
if $TEST -e $CODEPATH;  then
fp_print "Processing ($curnum of $endnum): $PACKAGE..."

#lets get existing permissions of CODEPATH
OLD_UGD=$( $LS -ln "$CODEPATH" )
OLD_PER=$( $ECHO $OLD_UGD | $CUT -d ' ' -f1 )
OLD_UID=$( $ECHO $OLD_UGD | $CUT -d ' ' -f3 )
OLD_GID=$( $ECHO $OLD_UGD | $CUT -d ' ' -f4 )

#apk source dirs
if $TEST "$APPDIR" = "/system/app"; then
#skip system apps if set
if $TEST "$NOSYSTEM" = "1"; then
fp_print "***SKIPPING SYSTEM APP ($PACKAGE)!"
return
fi
fp_chown_uid $OLD_UID 0 "$CODEPATH"
fp_chown_gid $OLD_GID 0 "$CODEPATH"
fp_chmod $OLD_PER "rw-r--r--" 644 "$CODEPATH"
elif $TEST "$APPDIR" = "/data/app" || $TEST "$APPDIR" = "/sd-ext/app"; then
fp_chown_uid $OLD_UID 1000 "$CODEPATH"
fp_chown_gid $OLD_GID 1000 "$CODEPATH"
fp_chmod $OLD_PER "rw-r--r--" 644 "$CODEPATH"
elif $TEST "$APPDIR" = "/data/app-private" || $TEST "$APPDIR" = "/sd-ext/app-private"; then
fp_chown_uid $OLD_UID 1000 "$CODEPATH"
fp_chown_gid $OLD_GID $LOCALGID "$CODEPATH"
fp_chmod $OLD_PER "rw-r-----" 640 "$CODEPATH"
fi
else
fp_print "$CODEPATH does not exist ($curnum of $endnum). Reinstall..."
if $TEST $REMOVE -eq 1; then
if $TEST -d /data/data/$PACKAGE ; then
fp_print "Removing stale dir /data/data/$PACKAGE"
if $TEST $SIMULATE -eq 0 ; then
$RM -R /data/data/$PACKAGE
fi
fi
fi
fi

#the data/data for the package
if $TEST -d "/data/data/$PACKAGE"; then
#find all directories in /data/data/$PACKAGE
$FIND /data/data/$PACKAGE -type d -exec $LS -ldn {} \; | while read dataline; do
#get existing permissions of that directory
OLD_PER=$( $ECHO $dataline | $CUT -d ' ' -f1 )
OLD_UID=$( $ECHO $dataline | $CUT -d ' ' -f3 )
OLD_GID=$( $ECHO $dataline | $CUT -d ' ' -f4 )
FILEDIR=$( $ECHO $dataline | $CUT -d ' ' -f9 )
FOURDIR=$( $ECHO $FILEDIR | $CUT -d '/' -f5 )

#set defaults for iteration
ISLIB=0
REVPERM=755
REVPSTR="rwxr-xr-x"
REVUID=$LOCALUID
REVGID=$LOCALGID

if $TEST "$FOURDIR" = ""; then
#package directory, perms:755 owner:$LOCALUID:$LOCALGID
fp_chmod $OLD_PER "rwxr-xr-x" 755 "$FILEDIR"
elif $TEST "$FOURDIR" = "lib"; then
#lib directory, perms:755 owner:1000:1000
#lib files, perms:755 owner:1000:1000
ISLIB=1
REVPERM=755
REVPSTR="rwxr-xr-x"
REVUID=1000
REVGID=1000
fp_chmod $OLD_PER "rwxr-xr-x" 755 "$FILEDIR"
elif $TEST "$FOURDIR" = "shared_prefs"; then
#shared_prefs directories, perms:771 owner:$LOCALUID:$LOCALGID
#shared_prefs files, perms:660 owner:$LOCALUID:$LOCALGID
REVPERM=660
REVPSTR="rw-rw----"
fp_chmod $OLD_PER "rwxrwx--x" 771 "$FILEDIR"
elif $TEST "$FOURDIR" = "databases"; then
#databases directories, perms:771 owner:$LOCALUID:$LOCALGID
#databases files, perms:660 owner:$LOCALUID:$LOCALGID
REVPERM=660
REVPSTR="rw-rw----"
fp_chmod $OLD_PER "rwxrwx--x" 771 "$FILEDIR"
elif $TEST "$FOURDIR" = "cache"; then
#cache directories, perms:771 owner:$LOCALUID:$LOCALGID
#cache files, perms:600 owner:$LOCALUID:$LOCALGID
REVPERM=600
REVPSTR="rw-------"
fp_chmod $OLD_PER "rwxrwx--x" 771 "$FILEDIR"
else
#other directories, perms:771 owner:$LOCALUID:$LOCALGID
REVPERM=771
REVPSTR="rwxrwx--x"
fp_chmod $OLD_PER "rwxrwx--x" 771 "$FILEDIR"
fi

#change ownership of directories matched
if $TEST "$ISLIB" = "1"; then
fp_chown_uid $OLD_UID 1000 "$FILEDIR"
fp_chown_gid $OLD_GID 1000 "$FILEDIR"
else
fp_chown_uid $OLD_UID $LOCALUID "$FILEDIR"
fp_chown_gid $OLD_GID $LOCALGID "$FILEDIR"
fi

#if any files exist in directory with improper permissions reset them
$FIND $FILEDIR -type f -maxdepth 1 ! -perm $REVPERM -exec $LS -ln {} \; | while read subline; do
OLD_PER=$( $ECHO $subline | $CUT -d ' ' -f1 )
SUBFILE=$( $ECHO $subline | $CUT -d ' ' -f9 )
fp_chmod $OLD_PER $REVPSTR $REVPERM "$SUBFILE"
done

#if any files exist in directory with improper user reset them
$FIND $FILEDIR -type f -maxdepth 1 ! -user $REVUID -exec $LS -ln {} \; | while read subline; do
OLD_UID=$( $ECHO $subline | $CUT -d ' ' -f3 )
SUBFILE=$( $ECHO $subline | $CUT -d ' ' -f9 )
fp_chown_uid $OLD_UID $REVUID "$SUBFILE"
done

#if any files exist in directory with improper group reset them
$FIND $FILEDIR -type f -maxdepth 1 ! -group $REVGID -exec $LS -ln {} \; | while read subline; do
OLD_GID=$( $ECHO $subline | $CUT -d ' ' -f4 )
SUBFILE=$( $ECHO $subline | $CUT -d ' ' -f9 )
fp_chown_gid $OLD_GID $REVGID "$SUBFILE"
done
done
fi
}

date_diff()
{
if $TEST $# -ne 2; then
FP_DDM="E"
FP_DDS="E"
return
fi
FP_DDD=$( $EXPR $2 - $1 )
FP_DDM=$( $EXPR $FP_DDD / 60 )
FP_DDS=$( $EXPR $FP_DDD % 60 )
}

fp_end()
{
if $TEST $SYSREMOUNT -eq 1; then
$MOUNT -o remount,ro $DEVICE /system > /dev/null 2>&1
fi

if $TEST $SYSSDMOUNT -eq 1; then
$UMOUNT $SD_EXT_DIRECTORY > /dev/null 2>&1
fi

if $TEST $SYSMOUNT -eq 1; then
$UMOUNT /system > /dev/null 2>&1
fi

if $TEST $DATAMOUNT -eq 1; then
$UMOUNT /data > /dev/null 2>&1
fi

FP_ENDTIME=$( $DATE +"%m-%d-%Y %H:%M:%S" )
FP_ENDEPOCH=$( $DATE +%s )

date_diff $FP_STARTEPOCH $FP_ENDEPOCH

fp_print "$0 $VERSION ended at $FP_ENDTIME (Runtime:${FP_DDM}m${FP_DDS}s)"
}

#MAIN SCRIPT

fp_parseargs $@
fp_start
if $TEST "$ONLY_ONE" != "" -a "$ONLY_ONE" != "0" ; then
fp_single "$ONLY_ONE"
else
fp_all
fi
fp_end

}

line=================================================

# Interface Construction

mainprocess() {

while [ 1 ]; do
$busyfusion clear
echo
echo "                 Script Fusion"
echo "                   Main Menu"
echo "                 *************"
echo
if [ $minfreq -gt 180000 ]; then
echo "1) CPU Frequency Profiles"
fi
echo "2) Customize CPU Profile"
echo "3) Scaling Governor Options"
echo "4) Scheduler Options Menu"
echo
echo "5) Fix Device Permissions"
echo "6) Binary Update Options"
echo
echo "7) View Current CPU Settings"
echo "8) View time-in-state (By Slot)"
echo "9) Ensure SetCPU Compatibility"
echo
echo "10) Backup voltage levels file"
echo "11) Restore voltage levels file"
echo
echo "12) Calibration / Cleanup"
echo "14) App Install Location"
echo "15) System Editing Options"
echo
echo "44) Updater-Script Editor"
echo "55) Swap Maintenance Menu"
echo "99) Tweak Customization Menu"
echo
echo "z) Download V6 SuperCharger"
echo "h) Script Help"
echo "0) Exit Script"
echo "x) Reboot Menu"
echo
echo "Release "`$busyfusion stat -c %y /data/data/com.fusion.tbolt/files/speedtweak.sh | $busyfusion sed 's/\.000000000//'`
echo "---"
echo -n "Please enter a number: "
read option
case $option in
1)
cpuprofiles
;;
2)
# custom
frequencyselect() {
echo
echo "Available Frequency Selections:"
echo `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies `

echo
echo "Min Frequency Selection"
echo "-----------------------"
n=1
while [ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $'$n' }'` ]
do
echo "$n: "`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $'$n' }'`
n=`$busyfusion expr $n + 1`
done
echo
echo "---"
echo -n "Please enter a number: "
read minfrequency
if [ "$minfrequency" == "" ]
then
minfrequency=$minfreq
fi
minimum=`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $'$minfrequency' }'`
minimumfreq='echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $'$minfrequency' }'`' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq'
$busyfusion clear
echo
echo "Available Frequency Selections:"
echo `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies`
echo
echo "Max Frequency Selection"
echo "-----------------------"
n=1
while [ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $'$n' }'` ]
do
echo "$n "`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $'$n' }'`
n=`$busyfusion expr $n + 1`
done
echo
echo "---"
echo -n "Please enter a number: "
read maxfrequency
if [ "$maxfrequency" == "" ]
then
maxfrequency=$maxfreq
fi
maximum=`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $'$maxfrequency' }'`
maximumfreq='echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $'$maxfrequency' }'`' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq'
if [ $maximum -lt $minimum ]
then
echo
echo "Max value must be higher than min"
echo "Max value was set to equal min value"
maximum=$minimum
maximumfreq='echo '$min' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq'
fi
}
$busyfusion clear
echo
echo "Configuration Choices"
echo "---------------------"
echo "1) Min and Max"
echo "2) Full Profile"
echo
echo "---"
echo -n "Please enter a number: "
read setcpupref
case $setcpupref in
1)
$busyfusion sed -i /scaling_/d $ifile
frequencyselect
echo '' >> $ifile
echo $minimumfreq >> $ifile
echo $maximumfreq >> $ifile
;;
2)
$busyfusion clear
echo
echo "Voltage Configuration"
echo "---------------------"
echo "#!/system/bin/sh" > $ifile
echo "# Mode: custom" >> $ifile
echo 'sysfile="/sys/devices/system/cpu/cpu0/cpufreq/vdd_levels"' >> $ifile
chmod 555 $ifile
n=1
while [ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $'$n' }'` ]
do
voltage=`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $'$n' }'`
echo "Current voltage for "`$busyfusion grep -m 1 -F $voltage /sys/devices/system/cpu/cpu0/cpufreq/vdd_levels`
if [ $n -gt 1 ]
then
voltmin=`$busyfusion grep -m 1 -F $minfreq /sys/devices/system/cpu/cpu0/cpufreq/vdd_levels | $busyfusion awk '{ print $2 }'`
voltdiff=`$busyfusion expr $voltage - $minfreq`
voltguess=`$busyfusion expr $voltdiff / 2000 + $voltmin`
echo "Recommended voltage for $voltage: ~ $voltguess"
fi
echo -n "Please enter a voltage for "`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $'$n' }'`" : "
read voltvalue
defaultvolt=`$busyfusion grep -m 1 -F $voltage /sys/devices/system/cpu/cpu0/cpufreq/vdd_levels | $busyfusion awk '{ print $2 }'`
if [ "$voltvalue" == "" ]
then
voltvalue=$defaultvolt
fi
echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | $busyfusion awk '{ print $'$n' }'`' '$voltvalue' > $sysfile' >> $ifile
echo
n=`$busyfusion expr $n + 1`
done
setcpumenu
;;
*)
;;
esac
sh $ifile
;;
3)
$busyfusion clear
echo
echo "Select Scaling Governor"
echo "-----------------------"
echo "Currently using "`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`
echo
echo "Available Governor Selections:"
echo `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors`
echo
n=1
while [ `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors | $busyfusion awk '{ print $'$n' }'` ]
do
echo $n': '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors | $busyfusion awk '{ print $'$n' }'`
n=`$busyfusion expr $n + 1`
done
echo
echo -n "Please choose a governor: "
read option
if [ ! "$option" == "" ]; then
$busyfusion sed -i /scaling_governor/d $ifile
echo
echo `$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors | $busyfusion awk '{ print $'$option' }'` > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 'echo '`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors | $busyfusion awk '{ print $'$option' }'`' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor' >> $ifile
echo "Completed. "`$busyfusion cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors | $busyfusion awk '{ print $'$option' }'`" has been chosen"
fi
;;
4)
extended()
{
$busyfusion clear
echo
echo "Kernel Extended Options"
echo "-----------------------"
echo "Kernel has these extra settings:"
$busyfusion cat /sys/kernel/debug/sched_features | $busyfusion sed 's/ /\n/g'
echo
echo "Would you like to apply generic tweaks?"
echo
echo "1: Yes"
echo "2: No"
echo
echo "0: Exit Menu"
echo
echo "---"
echo -n "Please choose an option: "
read extendedopt
case $extendedopt in
1)
echo
echo "NEW_FAIR_SLEEPERS" > /sys/kernel/debug/sched_features
echo "NO_NORMALIZED_SLEEPER" > /sys/kernel/debug/sched_features
echo "Extended options applied. Kernel modified"
;;
2)
echo
echo "Extended options cancelled. Kernel unchanged"
;;
*)
;;
esac
$busyfusion umount /sys/kernel/debug
}
$busyfusion clear
echo
schednoop=`$busyfusion grep -oFe "[noop]" /sys/block/mmcblk0/queue/scheduler`
scheddead=`$busyfusion grep -oFe "[deadline]" /sys/block/mmcblk0/queue/scheduler`
schedcfq=`$busyfusion grep -oFe "[cfq]" /sys/block/mmcblk0/queue/scheduler`
schedvr=`$busyfusion grep -oFe "[vr]" /sys/block/mmcblk0/queue/scheduler`
schedbfq=`$busyfusion grep -oFe "[bfq]" /sys/block/mmcblk0/queue/scheduler`
echo "dreamKernel Scheduler Options"
echo "-----------------------------"
if [ $schednoop ]
then
echo "Currently using [ No-Op ]"
elif [ $scheddead ]
then
echo "Currently using [ Deadline ]"
elif [ $schedcfq ]
then
echo "Currently using [ CFQ ]"
elif [ $schedvr ]
then
echo "Currently using [ V/R ]"
elif [ $schedbfq ]
then
echo "Currently using [ BFQ ]"
else
echo "Currently using [ Unknown ]"
fi
echo
echo "Available Scheduler Selections:"
echo `$busyfusion cat /sys/block/mmcblk0/queue/scheduler`
echo
n=1
while [ `$busyfusion cat /sys/block/mmcblk0/queue/scheduler | $busyfusion awk '{ print $'$n' }'` ]
do
nowschedule=`$busyfusion cat /sys/block/mmcblk0/queue/scheduler | $busyfusion awk '{ print $'$n' }' | $busyfusion sed 's/\[//' | $busyfusion sed 's/\]//'`
if [ "$nowschedule" == "noop" ]
then
echo "$n: No-Op (Not Recommended)"
elif [ "$nowschedule" == "deadline" ]
then
echo "$n: Deadline"
elif [ "$nowschedule" == "cfq" ]
then
echo "$n: CFQ (Good)"
elif [ "$nowschedule" == "vr" ]
then
echo "$n: V/R (Better)"
elif [ "$nowschedule" == "bfq" ]
then
echo "$n: BFQ (Best)"
else
echo $n": "`$busyfusion cat /sys/block/mmcblk0/queue/scheduler | $busyfusion awk '{ print $'$n' }'`
fi
n=`$busyfusion expr $n + 1`
done
echo
echo "---"
echo -n "Please choose a scheduler: "
read selected
echo
if [ ! "$selected" == "" ]; then
itemselect=`$busyfusion cat /sys/block/mmcblk0/queue/scheduler | $busyfusion awk '{ print $'$selected' }' | $busyfusion sed 's/\[//' | $busyfusion sed 's/\]//'`
echo "#!/system/bin/sh" > $sfile
echo "echo "$itemselect" > /sys/block/mmcblk0/queue/scheduler" >> $sfile
echo "Completed. "$itemselect" has been chosen"
sh $sfile
echo
echo "All Block Devices"
echo "-----------------"
echo "1) Use Selection"
echo "2) Use Default"
echo
echo "---"
echo -n "Please enter a number: "
read blockpref
case $blockpref in
1)
# yes
for i in `$busyfusion ls -1 /sys/block/mtdblock*` /sys/block/mmcblk0
do
echo $itemselect > $i/queue/scheduler
done
;;
*)
# no

;;
esac
$busyfusion mount -t debugfs none /sys/kernel/debug
if [ -e /sys/kernel/debug/sched_features ]
then
extended
fi
fi
;;
5)
# permissions

#!/system/bin/sh<<EOF

fixedpermission
echo
echo "Fix permissions completed. Please reboot"
echo

EOF

;;
6)
# binaries

#!/system/bin/sh<<EOF

binaryinstall

EOF

;;
7)
echo
cat /sys/devices/system/cpu/cpu0/cpufreq/vdd_levels
echo
echo -n "min: "
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo -n "max: "
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo -n "governor: "
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "You appear to be running "`grep Mode $ifile | awk '{ print $3 }'` "mode, am i right?"
;;
8)
echo
cat /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state
;;
9)
$busyfusion sed -i /scaling_/d $ifile
echo "Governor and min/max freqs removed from $ifile - you can now use SetCPU to set min/max freqs and governor."
;;
10)
$busyfusion clear
echo
echo "Select Backup Location"
echo "----------------------"
echo "1) Backup to Internal"
echo "2) Backup to SDcard"
echo
echo "0) Exit Menu"
echo
echo "---"
echo -n "Please enter a number: "
read savelocation
case $savelocation in
1)
# data
sfile="/data/Voltages.bak"
cp $ifile $sfile
echo
echo "Backup to INTERNAL complete"
;;
2)
# sdcard
sfile="/sdcard/ScriptFusion/Voltages.bak"
cp $ifile $sfile
echo
echo "Backup to SDCARD complete"
;;
*)
;;
esac
;;
11)
$busyfusion clear
echo
echo "Select Restore Location"
echo "-----------------------"
echo "1) Restore from Internal"
echo "2) Restore from SDcard"
echo
echo "0) Exit Menu"
echo
echo "---"
echo -n "Please enter a number: "
read backlocation
case $backlocation in
1)
# data
sfile="/data/Voltages.bak"
$busyfusion rm -rf $ifile
cp $sfile $ifile
chmod 555 $ifile
echo
echo "Restore from INTERNAL complete"
sh $ifile
;;
2)
# sdcard
sfile="/sdcard/ScriptFusion/Voltages.bak"
$busyfusion rm -rf $ifile
cp $sfile $ifile
chmod 555 $ifile
echo
echo "Restore from SDCARD complete"
sh $ifile
;;
*)
;;
esac
;;
12)
$busyfusion clear
echo
echo "Select Clear Parameters"
echo "-----------------------"
echo "1) Clear battery stats"
echo "2) Clear dalvik-cache"
echo "3) Clear stats + dalvik"
echo "4) Calibrate Wireless"
echo "5) Google Cache to SD"
echo
echo "0) Exit Menu"
echo
echo "---"
echo -n "Please enter a number: "
read clearlocate
case $clearlocate in
1)
$busyfusion rm -rf /data/system/batterystats.bin
$busyfusion rm -rf /cache/*
;;
2)
$busyfusion rm -rf /cache/*
$busyfusion rm -rf /data/dalvik-cache
;;
3)
$busyfusion rm -rf /cache/*
$busyfusion rm -rf /data/system/batterystats.bin
$busyfusion rm -rf /data/dalvik-cache
;;
4)
echo
cd /
$busyfusion rm -rf /data/data/com.android.settings/shared_prefs/WirelessSettings.xml
$busyfusion rm -rf /data/misc/wifi/
echo "nameserver 8.8.8.8" > /system/etc/resolv.conf
echo "nameserver 8.8.4.4" >> /system/etc/resolv.conf
echo "Calibration complete. Please reboot"
echo
sleep 1
;;
5)
if [ ! -d /sdcard/cache ]
then
mkdir /sdcard/cache
chmod 777 /sdcard/cache
fi
if [ ! -d /sdcard/cache/webviewCache ]
then
mkdir /sdcard/cache/webviewCache
chmod 777 /sdcard/cache/webviewCache
fi
if [ ! -d /sdcard/cache/files/maps ]
then
mkdir /sdcard/cache/files
mkdir /sdcard/cache/files/maps
chmod -r 777 /sdcard/cache/files
fi
if [ ! -d /sdcard/cache/streetCache ]
then
mkdir /sdcard/cache/streetCache
chmod 777 /sdcard/cache/streetCache
fi
if [ ! -d /sdcard/cache/marketCache ]
then
mkdir /sdcard/cache/marketCache
chmod 777 /sdcard/cache/marketCache
fi

# Browser Cache

cd /
cd /data/data/com.android.browser/cache
$busyfusion rm -rf webviewCache
$busyfusion ln -s /sdcard/cache/webviewCache webviewCache

# Gmail

cd /
cd /data/data/com.google.android.gm/cache
$busyfusion rm -rf webviewCache
$busyfusion ln -s /sdcard/cache/webviewCache webviewCache

# Voice Search

cd /
cd /data/data/com.google.android.voicesearch/cache
$busyfusion rm -rf webviewCache
$busyfusion ln -s /sdcard/cache/webviewCache webviewCache

# Google Maps

cd /
cd /data/data/com.google.android.apps.maps
$busyfusion rm -rf files
$busyfusion ln -s /sdcard/cache/files/maps files

# Google StreetView

cd /
cd /data/data/com.google.android.street
$busyfusion rm -rf cache
$busyfusion ln -s /sdcard/cache/streetCache cache

# Market Cache

cd /
cd /data/data/com.android.vending
$busyfusion rm -rf cache
$busyfusion ln -s /sdcard/cache/marketCache cache

echo "Google cache files moved to sdcard"
echo
cd /
;;
*)
;;
esac
;;
14)
$busyfusion clear
echo
echo "Select Install Location"
echo "-----------------------"
echo "Current location: "`pm getInstallLocation`
echo
echo "1) Automatic"
echo "2) Internal"
echo "3) External"
echo
echo "0) Exit Menu"
echo
echo "---"
echo -n "Please enter a number: "
read inslocation
case $inslocation in
1)
pm setInstallLocation 0
echo
echo "Install location set to automatic pick"
;;
2)
pm setInstallLocation 1
echo
echo "Install location set to internal only"
;;
3)
pm setInstallLocation 2
echo
echo "Install location set to external only"
echo
am start -a android.intent.action.MAIN -n com.android.settings/.Settings
;;
*)
;;
esac
;;
15)
systemoptions
;;
44)
$busyfusion clear
echo
echo "Updater-Script Editor"
echo "---------------------"
echo "Please enter META-INF location : "
echo -n "(Example: extracted) /sdcard/"
read custupdater
updaterlocation="/sdcard/"$custupdater"/META-INF/com/google/android/updater-script"
if [ ! -e $updaterlocation ]
then
echo
echo "Updater-Script not found. Please locate"
echo
else
cp $updaterlocation /sdcard/updater-script.bak
dataformat='format("ext3", "EMMC", "\/dev\/block\/mmcblk0p26");'
$busyfusion sed -i "/$dataformat/d" $updaterlocation
echo
updatertest=`$busyfusion grep -F 'format("ext3", "EMMC", "/dev/block/mmcblk0p26");' $updaterlocation`
if [ $updatertest ]
then
echo "Updater-Script was NOT edited. Try again"
echo
else
echo "Updater-Script edited. Replace in META-INF"
echo
fi
fi
;;
55)
# swapoptions
$busyfusion clear
echo
echo "Swap Maintenance Menu"
echo "---------------------"
echo "1) Create Swap"
echo "2) Remove Swap"
echo
echo "0) Swap Status"
echo
echo "---"
echo -n "Please enter a number: "
read swapoption
case $swapoption in
1)
# create
if [ -f /data/swapfile ]
then
swapoff /data/swapfile
$busyfusion rm -rf /data/swapfile
fi
echo
echo "Creating swap, Please wait..."
echo
$busyfusion dd if=/dev/zero of=/data/swapfile bs=1k count=200000 > /dev/null
chmod 777 /data/swapfile
$busyfusion mkswap /data/swapfile > /dev/null
$busyfusion swapon /data/swapfile
echo "100,200,20000,20000,20000,25000" > /sys/module/lowmemorykiller/parameters/minfree
$busyfusion sysctl -w vm.swappiness=40
echo
echo "Swap creation complete. Testing swap"
echo
if [ ! -e /system/etc/init.d/99imoseyon ]
then
echo "#!/system/bin/sh" > $tfile

echo "# Customized Tweaks" >> $tfile
echo "" >> $tfile
echo "# Scheduler Options" >> $tfile
echo "sh "$sfile >> $tfile
echo "" >> $tfile

echo "# Swapfile If Then Enable" >> $tfile
echo "if [ -e /data/swapfile ]" >> $tfile
echo "then" >> $tfile
echo "swapon /data/swapfile" >> $tfile
echo 'echo "100,200,20000,20000,20000,25000" > /sys/module/lowmemorykiller/parameters/minfree' >> $tfile
echo "sysctl -w vm.swappiness=40" >> $tfile
echo "fi" >> $tfile
echo "" >> $tfile
fi
free
echo
valueone=`free | $busyfusion awk '{ print $2 }' | $busyfusion sed -n 2p`
valuetwo=`free | $busyfusion awk '{ print $2 }' | $busyfusion sed -n 4p`
if [ $valuetwo ]
then
finalvalue=`$busyfusion expr $valueone + $valuetwo`
else
finalvalue=$valueone
fi
echo 'Current total available RAM:'$finalvalue
stockread=`$busyfusion grep ro.product.ram /system/build.prop | $busyfusion awk '{ print $3 }' | $busyfusion sed 's/MB//'`
if [ $stockread ]
then
stockvalue=`$busyfusion expr $stockread \* 1000`
differential=`$busyfusion expr $finalvalue - $stockvalue`
echo $differential' to '$stockvalue' Advertised RAM'
fi
;;
2)
# remove
echo
echo "Removing swap, Please wait..."
swapoff /data/swapfile
$busyfusion rm -rf /data/swapfile
echo
echo "Swap removal complete. Testing removal"
echo
free
echo
valueone=`free | $busyfusion awk '{ print $2 }' | $busyfusion sed -n 2p`
valuetwo=`free | $busyfusion awk '{ print $2 }' | $busyfusion sed -n 4p`
if [ $valuetwo ]
then
finalvalue=`$busyfusion expr $valueone + $valuetwo`
else
finalvalue=$valueone
fi
echo 'Current total available RAM:'$finalvalue
stockread=`$busyfusion grep ro.product.ram /system/build.prop | $busyfusion awk '{ print $3 }' | $busyfusion sed 's/MB//'`
if [ $stockread ]
then
stockvalue=`$busyfusion expr $stockread \* 1000`
differential=`$busyfusion expr $finalvalue - $stockvalue`
echo $differential' to '$stockvalue' Advertised RAM'
fi
;;
*)
echo
free
echo
valueone=`free | $busyfusion awk '{ print $2 }' | $busyfusion sed -n 2p`
valuetwo=`free | $busyfusion awk '{ print $2 }' | $busyfusion sed -n 4p`
if [ $valuetwo ]
then
finalvalue=`$busyfusion expr $valueone + $valuetwo`
else
finalvalue=$valueone
fi
echo 'Current total available RAM:'$finalvalue
stockread=`$busyfusion grep ro.product.ram /system/build.prop | $busyfusion awk '{ print $3 }' | $busyfusion sed 's/MB//'`
if [ $stockread ]
then
stockvalue=`$busyfusion expr $stockread \* 1000`
differential=`$busyfusion expr $finalvalue - $stockvalue`
echo $differential' to '$stockvalue' Advertised RAM'
fi
;;
esac
;;
99)

#!/system/bin/sh<<EOF

cd /

defaulttweak

tweakoptions

EOF

;;
h)
$viewitem $server/ScriptFusion/
;;
x)
$busyfusion clear
echo
echo "Reboot Options Menu"
echo "---------------------"
echo "1) Normal"
echo "2) Recovery"
echo "3) Bootloader"
echo
echo "x) Cancel"
echo
echo "---"
echo -n "Please choose an option: "
read configtype
case $configtype in
1)
reboottype=`$rebootfusion`
;;
2)
reboottype=`$rebootfusion recovery`
;;
3)
reboottype=`$rebootfusion bootloader`
;;
*)
;;
esac
$busyfusion clear
splashlogo
sleep 1
if [ $reboottype ]
then
$reboottype
fi
;;
z)
$viewitem http://forum.xda-developers.com/showpost.php?p=15948434&postcount=1127
;;
*)
$busyfusion mount -o remount,ro -t yaffs2 `$busyfusion grep /system /proc/mounts | $busyfusion cut -d' ' -f1` /system
$busyfusion mount -o ro,remount /system
$busyfusion mount -o ro,remount /
echo
echo "All set! Beware: SetCPU can override min/max."
echo
sleep 1
$busyfusion clear
echo
exit
;;
esac

echo
echo -n "Please hit Enter to continue:"
read key
done
}

line=================================================

if [ "$1" == "guilty" ]; then

wetinitialize
echo
if [ -e /system/etc/install-recovery.sh ]
then
$busyfusion rm -rf /system/etc/install-recovery.sh
fi
if [ -e /system/etc/sysctl.conf ]
then
$busyfusion rm -rf /system/etc/sysctl.conf
fi
if [ -e /system/etc/init.d/03twist_override ]
then
$busyfusion rm -rf /system/etc/init.d/03twist_override
fi
if [ -e /system/etc/init.d/00twist_override ]
then
$busyfusion rm -rf /system/etc/init.d/00twist_override
fi
if [ -e /system/etc/init.d/99imotwist_tweaks ]
then
$busyfusion rm -rf /system/etc/init.d/99imotwist_tweaks
fi
if [ -e /system/etc/init.d/99imoseyon ]
then
$busyfusion rm -rf /system/etc/init.d/99imoseyon
fi
generatevoltages
generateschedule
if [ -d /sdcard/scriptfusion/backup ]
then
$busyfusion mv -f /sdcard/scriptfusion/backup* /system/etc/init.d/
chmod 555 /system/etc/init.d/*
fi
if [ -e /data/data/com.fusion.tbolt/files/speedtweak.sh ]
then
$busyfusion rm -rf /data/data/com.fusion.tbolt/files/speedtweak.sh
fi
echo "ScriptFusion GUILTY! Sentenced to death"
exit

elif [ "$1" == "fusion" ]; then

$busyfusion mount -o remount,rw -t yaffs2 `$busyfusion grep /system /proc/mounts | $busyfusion cut -d' ' -f1` /system
$busyfusion mount -o rw,remount /system
$busyfusion mount -o rw,remount /

buildproperties

if [ ! -d /system/etc/init.d ]
then
mkdir /system/etc/init.d
chmod 755 /system/etc/init.d
fi

if [ -e /system/etc/init.d ]
then
if [ ! -d /sdcard/ScriptFusion ]
then
mkdir /sdcard/ScriptFusion
fi
if [ ! -d /sdcard/ScriptFusion/backup ]
then
mkdir /sdcard/ScriptFusion/backup
fi
$busyfusion mv -f /system/etc/init.d/* /sdcard/ScriptFusion/backup/
fi

generatevoltages

generateschedule

generatesysctl

generateoverride

dryinitialize

wetinitialize
updateprocess

$busyfusion mount -o ro,remount /
$busyfusion mount -o ro,remount /system
$busyfusion mount -o remount,ro -t yaffs2 `$busyfusion grep /system /proc/mounts | $busyfusion cut -d' ' -f1` /system

else
reboot='1'

wetinitialize

echo "Verifying ScriptFusion..."
sleep 1

if [ -e /system/customize/speedtweak.sh ]
then
$busyfusion rm -rf /system/customize/speedtweak.sh
if [ -e /system/etc/install-recovery.sh ]
then
$busyfusion rm -rf /system/etc/install-recovery.sh
fi
if [ -e /system/etc/init.d/00twist_override ]
then
$busyfusion rm -rf /system/etc/init.d/00twist_override
fi
fi

if [ ! $checkinitial ] && [ ! $checkaosp ]
then
if [ -f /system/etc/install-recovery.sh ]
then
$busyfusion rm -rf /system/etc/install-recovery.sh
fi
fi
if [ -e /system/bin/tweakrepair ]
then
$busyfusion rm -rf /system/bin/tweakrepair
fi

if [ -e /system/etc/init.d/03twist_override ]
then
$busyfusion rm -rf /system/etc/init.d/03twist_override
fi

if [ ! -d /sdcard/ScriptFusion ]
then
mkdir /sdcard/ScriptFusion
fi
if [ ! -d /sdcard/ScriptFusion/backup ]
then
mkdir /sdcard/ScriptFusion/backup
fi

if [ -e /data/data/imoseyon*.backup ]
then
$busyfusion mv -f /data/data/imoseyon*.backup /data/Voltages.bak
fi
if [ -e /sdcard/imoseyon*.backup ]
then
$busyfusion mv -f /sdcard/imoseyon*.backup /sdcard/ScriptFusion/Voltages.bak
fi

if [ -e /sdcard/ScriptFusion/backup/99imoseyon ]
then
$busyfusion mv -f /sdcard/ScriptFusion/backup/99imoseyon $tfile
chmod 555 $tfile
fi
if [ -e /sdcard/ScriptFusion/backup/99imotwist_tweaks ]
then
$busyfusion mv -f /data/scriptfusion/99imotwist_tweaks $tfile
chmod 555 $tfile
fi
if [ -e /sdcard/ScriptFusion/backup/02sched_choice ]
then
$busyfusion mv -f /sdcard/ScriptFusion/backup/02sched_choice $sfile
chmod 555 $sfile
fi
if [ -e /sdcard/ScriptFusion/backup/01vdd_levels ]
then
$busyfusion mv -f /sdcard/ScriptFusion/backup/01vdd_levels $ifile
chmod 555 $ifile
fi
if [ -e /sdcard/ScriptFusion/backup/03twist_override ]
then
$busyfusion rm -rf /sdcard/ScriptFusion/backup/03twist_override
fi
if [ -e /sdcard/ScriptFusion/backup/00twist_override ]
then
$busyfusion rm -rf /sdcard/ScriptFusion/backup/00twist_override
fi

if [ -e /system/etc/init.d/99imoseyon ]
then
$busyfusion mv -f /system/etc/init.d/99imoseyon $tfile
chmod 555 $tfile
fi

if [ $customsys ]
then
generatesysctl
fi

if [ ! -e $ifile ]
then
generatevoltages
fi

if [ ! -e $sfile ]
then
generateschedule
fi

if [ ! -e $ofile ]
then
generateoverride
fi

if [ -e $tfile ]
then
tweakdate=`$busyfusion stat -c %Y $tfile`
scriptdate=`$busyfusion stat -c %Y /data/data/com.fusion.tbolt/files/speedtweak.sh`
if [ $scriptdate -gt $tweakdate ]
then
defaulttweak
fi
fi

#!/system/bin/sh<<EOF

updateprocess

EOF

#!/system/bin/sh<<EOF

mainprocess

$busyfusion mount -o ro,remount /
$busyfusion mount -o ro,remount /system
$busyfusion mount -o remount,ro -t yaffs2 `$busyfusion grep /system /proc/mounts | $busyfusion cut -d' ' -f1` /system

EOF

fi
