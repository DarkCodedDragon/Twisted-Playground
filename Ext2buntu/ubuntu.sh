#!/system/bin/sh

# Copyright (C) 2011 Twisted Playground

server="http://twistedumbrella.github.com/Twisted-Playground"
checkubuntu=`busybox mountpoint /data/ubuntu | busybox  grep -F "not" -q`
busycheck=`busybox | busybox head -n 1 | busybox awk '{ print $2 }'`
wgetcheck=`busybox stat -c %s /system/xbin/wget`

scripts ()
{
   cd /
   echo
   echo "Unmounting Ubuntu from system"
   if [ $checkubuntu ]
   then
      busybox umount $mnt/dev/pts
      busybox umount $mnt/proc
      busybox umount $mnt/sys
      busybox fuser -k $mnt
      busybox umount $mnt
   fi
   sleep 1
   echo
   if [ -e /sdcard/ext2ubuntu/bootubuntu ]
   then
      cp /sdcard/ext2ubuntu/bootubuntu /system/bin/
      chmod 777 /system/bin/bootubuntu
   fi
   if [ -e /sdcard/ext2ubuntu/loopubuntu ]
   then
      cp /sdcard/ext2ubuntu/loopubuntu /system/bin/
      chmod 777 /system/bin/loopubuntu
   fi
   cp /sdcard/ext2ubuntu/backubuntu /system/bin/
   chmod 777 /system/bin/backubuntu
   if [ -e /sdcard/ext2ubuntu/bootubuntu ]
   then
      echo "Type bootubuntu to launch Ubuntu ext2"
      echo
   fi
   if [ -e /sdcard/ext2ubuntu/loopubuntu ]
   then
      echo "Type loopubuntu to launch Ubuntu loop"
      echo
   fi
   echo "Type backubuntu to launch Ubuntu Services"
   echo
   echo "Remounting system partition as read-only"
   busybox mount -o ro,remount /system
   busybox mount -o remount,ro -t yaffs2 `busybox grep /system /proc/mounts | busybox cut -d' ' -f1` /system
   echo
   exit
}

export mnt=/data/ubuntu

cd /
busybox clear
if [ ! -d /sdcard/ext2ubuntu ]
then
   mkdir /sdcard/ext2ubuntu
fi
echo
echo "Remounting system partition as read-write"
busybox mount -o rw,remount /system
busybox mount -o remount,rw -t yaffs2 `busybox grep /system /proc/mounts | busybox cut -d' ' -f1` /system
echo "Allowing Sdcard Script Execute..."
availablemounts=`busybox ls -x /dev/block/vold | busybox awk '{ print $2 }'`
if [ $availablemounts ]
then
   busybox mount -o remount,exec $availablemounts
fi
sleep 1
echo
echo "Verifying Binary Compatibility..."
echo

if [ $busycheck ]
then
   echo $busycheck" found"
else
   echo "Busybox not found. Script will exit"
   exit
fi

if [ -h /system/xbin/wget ]
then
   echo "Updating wget binary to custom version..."
   echo
   busybox rm -rf /system/xbin/wget
   busybox wget -O /system/xbin/wget $server/ScriptFusion/binaryfiles/wget
   chmod 755 /system/xbin/wget
elif [ $wgetcheck -lt 24000 ]
then
   echo "Updating wget binary to custom version..."
   echo
   busybox rm -rf /system/xbin/wget
   busybox wget -O /system/xbin/wget $server:/ScriptFusion/binaryfiles/wget
   chmod 755 /system/xbin/wget
fi
if [ $wgetcheck -gt 24000 ]
then
   
   if [ ! -d $mnt ]
   then
      mkdir $mnt
      chmod 777 $mnt
   fi
   busybox clear
   echo
   echo "************************************************"
   echo "*                                              *"
   echo "*           Ext2buntu Installation             *"
   echo "*          by Twisted Playground         *"
   echo "*                                              *"
   echo "************************************************"
   echo
   echo "Ubuntu folder should be in /sdcard/ubuntu"
   echo "For ext2 method, please also confirm:"
   echo "SDcard should have ext2 second partition"
   echo "Image and partition size must match"
   echo
   echo "Ext2buntu Access Method"
   echo "-----------------------"
   echo "1) Partition (Ext2)"
   echo "2) Loop (Mounted Image)"
   echo "3) Internal (Droid 2)"
   echo
   echo "0) Ubuntu Scripts Only"
   echo
   echo "x) Abort Install"
   echo
   echo "---"
   echo -n "Please choose your installation: "
   read setcpupref
   case $setcpupref in
      1)
         # ext2
         echo "Downloading updated install files"
         echo
         echo "nameserver 8.8.8.8" > /system/etc/resolv.conf
         echo "nameserver 8.8.4.4" >> /system/etc/resolv.conf
         wget -O /sdcard/ext2ubuntu/backubuntu $server/Ext2buntu/backubuntu
         echo
         wget -O /sdcard/ext2ubuntu/bootubuntu $server/Ext2buntu/bootubuntu
         echo
         echo "Update has been completed. Starting install"
         echo
         echo
         echo "Mounting partition to extract Ubuntu"
         availablemounts=`busybox ls -x /dev/block/vold | busybox awk '{ print $3 }'`
         if [ $availablemounts ]
         then
            busybox mount -o rw,noatime,nodiratime,nobh -t ext2 /dev/block/vold/$availablemounts $mnt
         else
            echo
            echo "Partition NOT located. Process will fail"
            sleep 1
         fi
         busybox clear
         echo
         echo "Modified installation for Ext2"
         echo "Ext2buntu Install Method"
         echo "------------------------"
         echo "1) Archive (.tar)"
         echo "2) Image (.img)"
         echo
         echo "0) Skip"
         echo
         echo "---"
         echo -n "Please choose an option: "
         read imagelocate
         case $imagelocate in
            1)
               # tar
               echo
               echo "Ext2buntu Archive Method"
               echo "------------------------"
               echo "1) Download"
               echo "2) Local"
               echo
               echo "---"
               echo -n "Please choose an option: "
               read imageselect
               case $imageselect in
                  1)
                     busybox clear
                     busybox mount -o rw,noatime,nodiratime,nobh -t ext2 $mountdir $mnt
                     wget -O /sdcard/ext2ubuntu/ubuntu11.04.tar http://50.17.242.125/0/view/id0fj5xuu23blx1/Ubuntu2Android/ubuntu11.04.tar
                     echo
                     tararchive="/sdcard/ext2ubuntu/ubuntu11.04.tar"
                     echo "Extracting core image to partition"
                     busybox tar xf $tararchive -C $mnt
                     echo
                     echo "Transfer to ext2 completed"
                  ;;
                  2)
                     busybox clear
                     busybox mount -o rw,noatime,nodiratime,nobh -t ext2 $mountdir $mnt
                     echo
                     echo "Select Image Name"
                     echo "-------------------"
                     #busybox find /sdcard/ext2ubuntu/ -maxdepth 1 -type f
                     n=1
                     for i in /sdcard/ext2ubuntu/*.tar
                     do
                        friendlyname=`busybox stat -c %n $i | busybox sed 's/\/sdcard\/ext2ubuntu\///'`
                        echo $n': '$friendlyname
                        n=`busybox expr $n + 1`
                     done
                     echo
                     echo "---"
                     echo -n "Please choose an image: "
                     read sysappsadd
                     if [ ! $sysappsadd == "" ]
                     then
                        for i in /sdcard/ext2ubuntu/*.tar
                        do
                           if [ $n == $sysappsadd ]
                           then
                              echo
                              echo "Extracting core image to partition"
                              busybox tar xf $i -C $mnt
                              echo
                              echo "Transfer to ext2 completed"
                           fi
                           n=`busybox expr $n + 1`
                        done
                     fi
                  ;;
                  *)
                     busybox clear
                     echo
                     echo "Select Image Name"
                     echo "-------------------"
                     #busybox find /sdcard/ext2ubuntu/ -maxdepth 1 -type f
                     n=1
                     for i in /sdcard/ext2ubuntu/*.tar
                     do
                        friendlyname=`busybox stat -c %n $i | busybox sed 's/\/sdcard\/ext2ubuntu\///'`
                        echo $n': '$friendlyname
                        n=`busybox expr $n + 1`
                     done
                     echo
                     echo "---"
                     echo -n "Please choose an image: "
                     read sysappsadd
                     if [ ! $sysappsadd == "" ]
                     then
                        for i in /sdcard/ext2ubuntu/*.tar
                        do
                           if [ $n == $sysappsadd ]
                           then
                              echo
                              echo "Extracting core image to partition"
                              busybox tar xf $i -C $mnt
                              echo
                              echo "Transfer to ext2 completed"
                           fi
                           n=`busybox expr $n + 1`
                        done
                     fi
                  ;;
               esac
            ;;
            2)
               # img
               busybox clear
               echo
               echo "Select Image Name"
               echo "-------------------"
               #busybox find /sdcard/ext2ubuntu/ -maxdepth 1 -type f
               n=1
               for i in /sdcard/ext2ubuntu/*.img
               do
                  friendlyname=`busybox stat -c %n $i | busybox sed 's/\/sdcard\/ext2ubuntu\///'`
                  echo $n': '$friendlyname
                  n=`busybox expr $n + 1`
               done
               echo
               echo "---"
               echo -n "Please choose an image: "
               read sysappsadd
               if [ ! $sysappsadd == "" ]
               then
                  for i in /sdcard/ext2ubuntu/*.img
                  do
                     if [ $n == $sysappsadd ]
                     then
                        echo "Installation has been started. Be patient"
                        busybox dd if=$i of= $mnt
                        echo
                        echo "Transfer to ext2 completed"
                     fi
                     n=`busybox expr $n + 1`
                  done
               fi
            ;;
            *)
            ;;
         esac
         scripts
      ;;
      2)
         # loop
         echo "Downloading updated install files"
         echo "nameserver 8.8.8.8" > /system/etc/resolv.conf
         echo "nameserver 8.8.4.4" >> /system/etc/resolv.conf
         wget -O /sdcard/ext2ubuntu/backubuntu $server/Ext2buntu/backubuntu
         echo
         wget -O /sdcard/ext2ubuntu/loopubuntu $server/Ext2buntu/loopubuntu
         echo
         echo "Update has been completed. Starting install"
         echo
         echo "Creating ubuntu2.img file for Ubuntu"
         busybox rm -rf /sdcard/ext2ubuntu/ubuntu2.img
         busybox dd if=/dev/zero of=/sdcard/ext2ubuntu/ubuntu2.img seek=4000999999 bs=1 count=1
         chmod 777 /sdcard/ext2ubuntu/ubuntu2.img
         busybox mke2fs -F /sdcard/ubuntu/ubuntu2.img
         # busybox mkfs.ext2 -F /sdcard/ext2ubuntu/ubuntu2.img
         echo
         echo "Mounting ubuntu2.img to extract Ubuntu"
         export mountpath=/dev/loop8
         busybox mknod -m660 $mountpath b 7 8
         busybox losetup $mountpath $kit/ubuntu.img
         busybox mount -t ext2 $mountpath $mnt
         busybox clear
         echo
         echo "Modified installation for Loop"
         echo "Ext2buntu Install Method"
         echo "------------------------"
         echo "1) Archive (.tar)"
         echo "2) Image (.img)"
         echo
         echo "0) Skip"
         echo
         echo "---"
         echo -n "Please choose an option: "
         read imagelocate
         case $imagelocate in
            1)
               # tar
               echo
               echo "Ubuntu image file created and formatted"
               echo
               echo "Ext2buntu Archive Method"
               echo "------------------------"
               echo "1) Download"
               echo "2) Local"
               echo
               echo "---"
               echo -n "Please choose an option: "
               read imageselect
               case $imageselect in
                  1)
                     busybox clear
                     wget -O /sdcard/ext2ubuntu/ubuntu11.04.tar http://50.17.242.125/0/view/id0fj5xuu23blx1/Ubuntu2Android/ubuntu11.04.tar
                     echo
                     tararchive="/sdcard/ext2ubuntu/ubuntu11.04.tar"
                     echo "Extracting core image to partition"
                     busybox tar xf $tararchive -C $mnt
                     echo
                     echo "Transfer to loop completed"
                  ;;
                  2)
                     busybox clear
                     echo
                     echo "Select Image Name"
                     echo "-------------------"
                     #busybox find /sdcard/ext2ubuntu/ -maxdepth 1 -type f
                     n=1
                     for i in /sdcard/ext2ubuntu/*.tar
                     do
                        friendlyname=`busybox stat -c %n $i | busybox sed 's/\/sdcard\/ext2ubuntu\///'`
                        echo $n': '$friendlyname
                        n=`busybox expr $n + 1`
                     done
                     echo
                     echo "---"
                     echo -n "Please choose an image: "
                     read sysappsadd
                     if [ ! $sysappsadd == "" ]
                     then
                        for i in /sdcard/ext2ubuntu/*.tar
                        do
                           if [ $n == $sysappsadd ]
                           then
                              echo
                              echo "Extracting core image to partition"
                              busybox tar xf $i -C $mnt
                              echo
                              echo "Transfer to loop completed"
                           fi
                           n=`busybox expr $n + 1`
                        done
                     fi
                  ;;
                  *)
                     busybox clear
                     echo
                     echo "Select Image Name"
                     echo "-------------------"
                     #busybox find /sdcard/ext2ubuntu/ -maxdepth 1 -type f
                     n=1
                     for i in /sdcard/ext2ubuntu/*.tar
                     do
                        friendlyname=`busybox stat -c %n $i | busybox sed 's/\/sdcard\/ext2ubuntu\///'`
                        echo $n': '$friendlyname
                        n=`busybox expr $n + 1`
                     done
                     echo
                     echo "---"
                     echo -n "Please choose an image: "
                     read sysappsadd
                     if [ ! $sysappsadd == "" ]
                     then
                        for i in /sdcard/ext2ubuntu/*.tar
                        do
                           if [ $n == $sysappsadd ]
                           then
                              echo
                              echo "Extracting core image to partition"
                              busybox tar xf $i -C $mnt
                              echo
                              echo "Transfer to loop completed"
                           fi
                           n=`busybox expr $n + 1`
                        done
                     fi
                  ;;
               esac
            ;;
            2)
               # img
               busybox clear
               echo
               echo "Using ubuntu2.img No modification necessary"
            ;;
            *)
            ;;
         esac
         scripts
      ;;
      3)
         # Droid2
         echo "Downloading updated install files"
         echo "nameserver 8.8.8.8" > /system/etc/resolv.conf
         echo "nameserver 8.8.4.4" >> /system/etc/resolv.conf
         wget -O /sdcard/ext2ubuntu/backubuntu $server/Ext2buntu/backubuntu
         echo
         wget -O /sdcard/ext2ubuntu/bootubuntu $server/Ext2buntu/bootubuntu
         echo
         echo "Update has been completed. Starting install"
         busybox clear
         echo
         echo "Modified installation for Droid2"
         echo "Ext2buntu Install Method"
         echo "------------------------"
         echo "1) Archive (.tar)"
         echo "2) Image (.img)"
         echo
         echo "0) Skip"
         echo
         echo "---"
         echo -n "Please choose an option: "
         read imagelocate
         case $imagelocate in
            1)
               # tar
               
               echo
               echo "Ext2buntu Archive Method"
               echo "------------------------"
               echo "1) Download"
               echo "2) Local"
               echo
               echo "---"
               echo -n "Please choose an option: "
               read imageselect
               case $imageselect in
                  1)
                     busybox clear
                     wget -O /sdcard/ext2ubuntu/ubuntu11.04.tar http://50.17.242.125/0/view/id0fj5xuu23blx1/Ubuntu2Android/ubuntu11.04.tar
                     echo
                     tararchive="/sdcard/ext2ubuntu/ubuntu11.04.tar"
                     echo "Extracting core image to partition"
                     busybox tar xf $tararchive -C $mnt
                     echo
                     echo "Transfer to internal completed"
                  ;;
                  2)
                     busybox clear
                     echo
                     echo "Select Image Name"
                     echo "-------------------"
                     #busybox find /sdcard/ext2ubuntu/ -maxdepth 1 -type f
                     n=1
                     for i in /sdcard/ext2ubuntu/*.tar
                     do
                        friendlyname=`busybox stat -c %n $i | busybox sed 's/\/sdcard\/ext2ubuntu\///'`
                        echo $n': '$friendlyname
                        n=`busybox expr $n + 1`
                     done
                     echo
                     echo "---"
                     echo -n "Please choose an image: "
                     read sysappsadd
                     if [ ! $sysappsadd == "" ]
                     then
                        for i in /sdcard/ext2ubuntu/*.tar
                        do
                           if [ $n == $sysappsadd ]
                           then
                              echo
                              echo "Extracting core image to partition"
                              busybox tar xf $i -C $mnt
                              echo
                              echo "Transfer to internal completed"
                           fi
                           n=`busybox expr $n + 1`
                        done
                     fi
                  ;;
                  *)
                     busybox clear
                     echo
                     echo "Select Image Name"
                     echo "-------------------"
                     #busybox find /sdcard/ext2ubuntu/ -maxdepth 1 -type f
                     n=1
                     for i in /sdcard/ext2ubuntu/*.tar
                     do
                        friendlyname=`busybox stat -c %n $i | busybox sed 's/\/sdcard\/ext2ubuntu\///'`
                        echo $n': '$friendlyname
                        n=`busybox expr $n + 1`
                     done
                     echo
                     echo "---"
                     echo -n "Please choose an image: "
                     read sysappsadd
                     if [ ! $sysappsadd == "" ]
                     then
                        for i in /sdcard/ext2ubuntu/*.tar
                        do
                           if [ $n == $sysappsadd ]
                           then
                              echo
                              echo "Extracting core image to partition"
                              busybox tar xf $i -C $mnt
                              echo
                              echo "Transfer to internal completed"
                           fi
                           n=`busybox expr $n + 1`
                        done
                     fi
                  ;;
               esac
            ;;
            2)
               # img
               busybox clear
               echo
               echo "Select Image Name"
               echo "-------------------"
               #busybox find /sdcard/ext2ubuntu/ -maxdepth 1 -type f
               n=1
               for i in /sdcard/ext2ubuntu/*.img
               do
                  friendlyname=`busybox stat -c %n $i | busybox sed 's/\/sdcard\/ext2ubuntu\///'`
                  echo $n': '$friendlyname
                  n=`busybox expr $n + 1`
               done
               echo
               echo "---"
               echo -n "Please choose an image: "
               read sysappsadd
               if [ ! $sysappsadd == "" ]
               then
                  for i in /sdcard/ext2ubuntu/*.img
                  do
                     if [ $n == $sysappsadd ]
                     then
                        echo "Installation has been started. Be patient"
                        busybox dd if=$i of= $mnt
                        echo
                        echo "Transfer to internal completed"
                     fi
                     n=`busybox expr $n + 1`
                  done
               fi
            ;;
            *)
            ;;
         esac
         scripts
      ;;
      0)
         # scripts
         wget -O /sdcard/ext2ubuntu/backubuntu $server/Ext2buntu/backubuntu
         if [ -e /sdcard/ext2ubuntu/bootubuntu ]
         then
            echo
            wget -O /sdcard/ext2ubuntu/bootubuntu $server/Ext2buntu/bootubuntu
         fi
         if [ -e /sdcard/ext2ubuntu/loopubuntu ]
         then
            echo
            wget -O /sdcard/ext2ubuntu/bootubuntu $server/Ext2buntu/loopubuntu
         fi
         scripts
      ;;
      x)
         echo
         exit
      ;;
   esac
   echo
else
   busybox clear
   echo
   echo "Invalid Binaries. Please retry"
   echo
fi
