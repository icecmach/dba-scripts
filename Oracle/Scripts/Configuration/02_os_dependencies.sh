echo "******************************************************************************"
echo "Add DNS 8.8.8.8 to /etc/resolv.conf" `date`
echo "******************************************************************************"
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

echo "******************************************************************************"
echo "Install OS Packages." `date`
echo "******************************************************************************"
dnf install -y dnf-utils zip unzip
dnf install -y oracle-database-preinstall-19c

echo "******************************************************************************"
echo "Firewall -> Stop service firewalld." `date`
echo "******************************************************************************"
systemctl stop firewalld
systemctl disable firewalld

echo "******************************************************************************"
echo "SELinux -> Set to permissive." `date`
echo "******************************************************************************"
sed -i -e "s|SELINUX=enabled|SELINUX=permissive|g" /etc/selinux/config
setenforce permissive
