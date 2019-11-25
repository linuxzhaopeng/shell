#!/bin/bash
#mount /dev/cdrom /mnt/cdrom
#引导文件路径使用默认
DHCP_mb='/usr/share/doc/dhcp*/dhcpd.conf.example'
DHCP_conf='/etc/dhcp/dhcpd.conf'
WK_ydwj='/usr/share/syslinux/pxelinux.0'
read -p '分配的网段,默认值为192.168.4.0' $wd
if [ -z "${wd}"];then
	wd='192.168.4.0'
fi
read -p '分配的子网掩码,默认为255.255.255.0' $zwym
if [ -z "${zwym}"];then
	zwym='255.255.255.0'
fi
read -p 'IP地址范围,默认值为:192.168.4.100 192.168.4.200' $dzfw
if [ -z "${dzfw}"];then
	dzfw='192.168.4.100 192.168.4.200'
fi
read -p 'DNS地址,默认值为:192.168.4.10' $DNS
if [ -z "${DNS}"];then
	DNS='192.168.4.10'
fi
read -p '网关地址,默认值为:192.168.4.254' $wgdz
if [ -z "${wgdz}"];then
	wgdz='192.168.4.254'
fi
read -p '下一个服务器位置,默认值为:192.168.4.10' $fwqwz
if [ -z "${fwqwz}"];then
	fwqwz='192.168.4.10'
fi
read -p '网卡引导文件,默认值为:pxelinux.0' $ydwj
if [ -z "${ydwj}"];then
	ydwj='pxelinux.0'
fi
yum -y remove dhcp tftp-server syslinux
yum -y install dhcp
sed -n '47,55p' $DHCP_mb >> $DHCP_conf
#删除不需要的行
sed -i '/internal/d' $DHCP_conf
sed -i  '/broadcast/d' $DHCP_conf
#分配的网段
sed -i "s/10.5.5.0/$wd/" $DHCP_conf
#分配的子网掩码
sed -i "s/255.255.255.224/$zwym/" $DHCP_conf
#分配的IP地址范围
sed -i  "/range/c range $dzfw;" $DHCP_conf
#分配的DNS地址
sed -i  "/range/a option domain-name-servers $DNS;" $DHCP_conf
#分配的网关地址
sed -i "s/10.5.5.1/$wgdz/" $DHCP_conf
#指定下一个服务器的位置
sed -i "/max-lease-time/ a next-server  $fwqwz;" $DHCP_conf
#添加网卡引导文件
sed -i '/next-server/ a filename  "pxelinux.0";' $DHCP_conf
systemctl restart dhcpd
yum -y install tftp-server syslinux
cp $WK_ydwj  /var/lib/tftpboot/
umount /mnt/pxe
rm -rf /mnt/pxe
#创建光驱挂在的位置
mkdir /mnt/pxe
[ -e /dev/cdrom ] && mount /dev/cdrom /mnt/pxe || echo '该设备不存在'
[ -d /var/lib/tftpboot/pxelinux.cfg ] && echo '该文件夹已存在' || mkdir /var/lib/tftpboot/pxelinux.cfg
#移动相关的文件
cd /mnt/pxe/isolinux/
awk 'NR<65' /mnt/pxe/isolinux/isolinux.cfg >  /var/lib/tftpboot/pxelinux.cfg/default
cp vesamenu.c32 splash.png vmlinuz initrd.img /var/lib/tftpboot/
#标题内容 
sed -i 's/menu title CentOS 7/ menu title NSD1907 PXE Server/' /var/lib/tftpboot/pxelinux.cfg/default
#读秒结束后的默认选项
sed -i '/kernel vmlinuz/ i menu default ' /var/lib/tftpboot/pxelinux.cfg/default
#加载驱动内核
sed -i '/initrd/c append initrd=initrd.img' /var/lib/tftpboot/pxelinux.cfg/default
systemctl restart tftp
yum -y install httpd
systemctl restart httpd
systemctl restart tftp
mkdir /var/www/html/centos
mount /dev/cdrom  /var/www/html/centos
sed -i   's/\[.*]/[development]/' /etc/yum.repos.d/local.repo
sed -i 's#initrd=initrd.img#initrd=initrd.img ks=http://192.168.4.10/ks.cfg#' /var/lib/tftpboot/pxelinux.cfg/default
cp ./ks.cfg /var/www/html/













