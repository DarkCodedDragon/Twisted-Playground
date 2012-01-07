#!/system/bin/sh

busyfusion="/data/data/com.fusion.tbolt/files/busybox"
wgetfusion="/data/data/com.fusion.tbolt/files/wget"
checkubuntu=`$busyfusion mountpoint /data/ubuntu | $busyfusion  grep -F "not" -q`

scripts ()
{
   cd /
   echo
   echo "Unmounting Ubuntu from system"
   if [ $checkubuntu ]
   then
      $busyfusion umount $mnt/dev/pts
      $busyfusion umount $mnt/proc
      $busyfusion umount $mnt/sys
      $busyfusion fuser -k $mnt
      $busyfusion umount $mnt
   fi
   sleep 1
   echo
   if [ -e /data/data/com.fusion.tbolt/files/ext2buntu/bootubuntu ]
   then
      cp /data/data/com.fusion.tbolt/files/ext2buntu/bootubuntu /system/bin/
      chmod 777 /system/bin/bootubuntu
   fi
   if [ -e /data/data/com.fusion.tbolt/files/ext2buntu/loopubuntu ]
   then
      cp /data/data/com.fusion.tbolt/files/ext2buntu/loopubuntu /system/bin/
      chmod 777 /system/bin/loopubuntu
   fi
   cp /data/data/com.fusion.tbolt/files/ext2buntu/backubuntu /system/bin/
   chmod 777 /system/bin/backubuntu
   if [ -e /data/data/com.fusion.tbolt/files/ext2buntu/bootubuntu ]
   then
      echo "Type bootubuntu to launch Ubuntu ext2"
      echo
   fi
   if [ -e /data/data/com.fusion.tbolt/files/ext2buntu/loopubuntu ]
   then
      echo "Type loopubuntu to launch Ubuntu loop"
      echo
   fi
   echo "Type backubuntu to launch Ubuntu Services"
   echo
   echo "Remounting system partition as read-only"
   $busyfusion mount -o ro,remount /system
   $busyfusion mount -o remount,ro -t yaffs2 `$busyfusion grep /system /proc/mounts | $busyfusion cut -d' ' -f1` /system
   echo
   exit
}

export mnt=/data/ubuntu

cd /
$busyfusion clear
if [ ! -d /data/data/com.fusion.tbolt/files/ext2buntu ]
then
   mkdir /data/data/com.fusion.tbolt/files/ext2buntu
fi
if [ ! -d /sdcard/ext2ubuntu ]
then
   mkdir /sdcard/ext2ubuntu
fi
echo
echo "Remounting system partition as read-write"
$busyfusion mount -o rw,remount /system
$busyfusion mount -o remount,rw -t yaffs2 `$busyfusion grep /system /proc/mounts | $busyfusion cut -d' ' -f1` /system
echo

if [ ! -d $mnt ]
then
   mkdir $mnt
   chmod 777 $mnt
fi
$busyfusion clear
echo
echo "************************************************"
echo "*                                              *"
echo "*           Ext2buntu Installation             *"
echo "*       Enriched by Twisted Playground         *"
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
      $wgetfusion -O /data/data/com.fusion.tbolt/files/ext2buntu/backubuntu http://twisted.dyndns.tv/Ext2buntu/application/backubuntu
      echo
      $wgetfusion -O /data/data/com.fusion.tbolt/files/ext2buntu/bootubuntu http://twisted.dyndns.tv/Ext2buntu/application/bootubuntu
      echo
      echo "Update has been completed. Starting install"
      echo
      echo
      echo "Mounting partition to extract Ubuntu"
      availablemounts=`$busyfusion ls -x /dev/block/vold | $busyfusion awk '{ print $3 }'`
      if [ $availablemounts ]
      then
         $busyfusion mount -o rw,noatime,nodiratime,nobh -t ext2 /dev/block/vold/$availablemounts $mnt
      else
         echo
         echo "Partition NOT located. Process will fail"
         sleep 1
      fi
      $busyfusion clear
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
                  $busyfusion clear
                  $busyfusion mount -o rw,noatime,nodiratime,nobh -t ext2 $mountdir $mnt
                  $wgetfusion -O /sdcard/ext2ubuntu/ubuntu11.04.tar http://50.17.242.125/0/view/id0fj5xuu23blx1/Ubuntu2Android/ubuntu11.04.tar
                  echo
                  tararchive="/sdcard/ext2ubuntu/ubuntu11.04.tar"
                  echo "Extracting core image to partition"
                  $busyfusion tar xf $tararchive -C $mnt
                  echo
                  echo "Transfer to ext2 completed"
               ;;
               2)
                  $busyfusion clear
                  $busyfusion mount -o rw,noatime,nodiratime,nobh -t ext2 $mountdir $mnt
                  echo
                  echo "Select Image Name"
                  echo "-------------------"
                  #$busyfusion find /sdcard/ext2ubuntu/ -maxdepth 1 -type f
                  n=1
                  for i in /sdcard/ext2ubuntu/*.tar
                  do
                     friendlyname=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\/ext2ubuntu\///'`
                     echo $n': '$friendlyname
                     n=`$busyfusion expr $n + 1`
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
                           $busyfusion tar xf $i -C $mnt
                           echo
                           echo "Transfer to ext2 completed"
                        fi
                        n=`$busyfusion expr $n + 1`
                     done
                  fi
               ;;
               *)
                  $busyfusion clear
                  echo
                  echo "Select Image Name"
                  echo "-------------------"
                  #$busyfusion find /sdcard/ext2ubuntu/ -maxdepth 1 -type f
                  n=1
                  for i in /sdcard/ext2ubuntu/*.tar
                  do
                     friendlyname=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\/ext2ubuntu\///'`
                     echo $n': '$friendlyname
                     n=`$busyfusion expr $n + 1`
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
                           $busyfusion tar xf $i -C $mnt
                           echo
                           echo "Transfer to ext2 completed"
                        fi
                        n=`$busyfusion expr $n + 1`
                     done
                  fi
               ;;
            esac
         ;;
         2)
            # img
            $busyfusion clear
            echo
            echo "Select Image Name"
            echo "-------------------"
            #$busyfusion find /sdcard/ext2ubuntu/ -maxdepth 1 -type f
            n=1
            for i in /sdcard/ext2ubuntu/*.img
            do
               friendlyname=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\/ext2ubuntu\///'`
               echo $n': '$friendlyname
               n=`$busyfusion expr $n + 1`
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
                     $busyfusion dd if=$i of= $mnt
                     echo
                     echo "Transfer to ext2 completed"
                  fi
                  n=`$busyfusion expr $n + 1`
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
      $wgetfusion -O /data/data/com.fusion.tbolt/files/ext2buntu/backubuntu http://twisted.dyndns.tv/Ext2buntu/application/backubuntu
      echo
      $wgetfusion -O /data/data/com.fusion.tbolt/files/ext2buntu/loopubuntu http://twisted.dyndns.tv/Ext2buntu/application/loopubuntu
      echo
      echo "Update has been completed. Starting install"
      echo
      echo "Creating ubuntu2.img file for Ubuntu"
      $busyfusion rm -rf /sdcard/ext2ubuntu/ubuntu2.img
      $busyfusion dd if=/dev/zero of=/sdcard/ext2ubuntu/ubuntu2.img seek=4000999999 bs=1 count=1
      chmod 777 /sdcard/ext2ubuntu/ubuntu2.img
      $busyfusion mke2fs -F /sdcard/ubuntu/ubuntu2.img
      # $busyfusion mkfs.ext2 -F /sdcard/ext2ubuntu/ubuntu2.img
      echo
      echo "Mounting ubuntu2.img to extract Ubuntu"
      export mountpath=/dev/loop8
      $busyfusion mknod -m660 $mountpath b 7 8
      $busyfusion losetup $mountpath $kit/ubuntu.img
      $busyfusion mount -t ext2 $mountpath $mnt
      $busyfusion clear
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
                  $busyfusion clear
                  $wgetfusion -O /sdcard/ext2ubuntu/ubuntu11.04.tar http://50.17.242.125/0/view/id0fj5xuu23blx1/Ubuntu2Android/ubuntu11.04.tar
                  echo
                  tararchive="/sdcard/ext2ubuntu/ubuntu11.04.tar"
                  echo "Extracting core image to partition"
                  $busyfusion tar xf $tararchive -C $mnt
                  echo
                  echo "Transfer to loop completed"
               ;;
               2)
                  $busyfusion clear
                  echo
                  echo "Select Image Name"
                  echo "-------------------"
                  #$busyfusion find /sdcard/ext2ubuntu/ -maxdepth 1 -type f
                  n=1
                  for i in /sdcard/ext2ubuntu/*.tar
                  do
                     friendlyname=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\/ext2ubuntu\///'`
                     echo $n': '$friendlyname
                     n=`$busyfusion expr $n + 1`
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
                           $busyfusion tar xf $i -C $mnt
                           echo
                           echo "Transfer to loop completed"
                        fi
                        n=`$busyfusion expr $n + 1`
                     done
                  fi
               ;;
               *)
                  $busyfusion clear
                  echo
                  echo "Select Image Name"
                  echo "-------------------"
                  #$busyfusion find /sdcard/ext2ubuntu/ -maxdepth 1 -type f
                  n=1
                  for i in /sdcard/ext2ubuntu/*.tar
                  do
                     friendlyname=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\/ext2ubuntu\///'`
                     echo $n': '$friendlyname
                     n=`$busyfusion expr $n + 1`
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
                           $busyfusion tar xf $i -C $mnt
                           echo
                           echo "Transfer to loop completed"
                        fi
                        n=`$busyfusion expr $n + 1`
                     done
                  fi
               ;;
            esac
         ;;
         2)
            # img
            $busyfusion clear
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
      $wgetfusion -O /data/data/com.fusion.tbolt/files/ext2buntu/backubuntu http://twisted.dyndns.tv/Ext2buntu/application/backubuntu
      echo
      $wgetfusion -O /data/data/com.fusion.tbolt/files/ext2buntu/bootubuntu http://twisted.dyndns.tv/Ext2buntu/application/bootubuntu
      echo
      echo "Update has been completed. Starting install"
      $busyfusion clear
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
                  $busyfusion clear
                  $wgetfusion -O /sdcard/ext2ubuntu/ubuntu11.04.tar http://50.17.242.125/0/view/id0fj5xuu23blx1/Ubuntu2Android/ubuntu11.04.tar
                  echo
                  tararchive="/sdcard/ext2ubuntu/ubuntu11.04.tar"
                  echo "Extracting core image to partition"
                  $busyfusion tar xf $tararchive -C $mnt
                  echo
                  echo "Transfer to internal completed"
               ;;
               2)
                  $busyfusion clear
                  echo
                  echo "Select Image Name"
                  echo "-------------------"
                  #$busyfusion find /sdcard/ext2ubuntu/ -maxdepth 1 -type f
                  n=1
                  for i in /sdcard/ext2ubuntu/*.tar
                  do
                     friendlyname=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\/ext2ubuntu\///'`
                     echo $n': '$friendlyname
                     n=`$busyfusion expr $n + 1`
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
                           $busyfusion tar xf $i -C $mnt
                           echo
                           echo "Transfer to internal completed"
                        fi
                        n=`$busyfusion expr $n + 1`
                     done
                  fi
               ;;
               *)
                  $busyfusion clear
                  echo
                  echo "Select Image Name"
                  echo "-------------------"
                  #$busyfusion find /sdcard/ext2ubuntu/ -maxdepth 1 -type f
                  n=1
                  for i in /sdcard/ext2ubuntu/*.tar
                  do
                     friendlyname=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\/ext2ubuntu\///'`
                     echo $n': '$friendlyname
                     n=`$busyfusion expr $n + 1`
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
                           $busyfusion tar xf $i -C $mnt
                           echo
                           echo "Transfer to internal completed"
                        fi
                        n=`$busyfusion expr $n + 1`
                     done
                  fi
               ;;
            esac
         ;;
         2)
            # img
            $busyfusion clear
            echo
            echo "Select Image Name"
            echo "-------------------"
            #$busyfusion find /sdcard/ext2ubuntu/ -maxdepth 1 -type f
            n=1
            for i in /sdcard/ext2ubuntu/*.img
            do
               friendlyname=`$busyfusion stat -c %n $i | $busyfusion sed 's/\/sdcard\/ext2ubuntu\///'`
               echo $n': '$friendlyname
               n=`$busyfusion expr $n + 1`
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
                     $busyfusion dd if=$i of= $mnt
                     echo
                     echo "Transfer to internal completed"
                  fi
                  n=`$busyfusion expr $n + 1`
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
      $wgetfusion -O /data/data/com.fusion.tbolt/files/ext2buntu/backubuntu http://twisted.dyndns.tv/Ext2buntu/application/backubuntu
      $wgetfusion -O /data/data/com.fusion.tbolt/files/ext2buntu/bootubuntu http://twisted.dyndns.tv/Ext2buntu/application/bootubuntu
      $wgetfusion -O /data/data/com.fusion.tbolt/files/ext2buntu/bootubuntu http://twisted.dyndns.tv/Ext2buntu/application/loopubuntu
      cp /data/data/com.fusion.tbolt/files/ext2buntu/bootubuntu /system/bin/
      chmod 777 /system/bin/bootubuntu
      cp /data/data/com.fusion.tbolt/files/ext2buntu/loopubuntu /system/bin/
      chmod 777 /system/bin/loopubuntu
      cp /data/data/com.fusion.tbolt/files/ext2buntu/backubuntu /system/bin/
      chmod 777 /system/bin/backubuntu
      echo
      echo "Type bootubuntu to launch Ubuntu ext2"
      echo
      echo "Type loopubuntu to launch Ubuntu loop"
      echo
      echo "Type backubuntu to launch Ubuntu Services"
   ;;
   x)
      echo
      exit
   ;;
esac
echo
