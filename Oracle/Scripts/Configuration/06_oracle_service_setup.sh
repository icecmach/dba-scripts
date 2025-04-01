echo "******************************************************************************"
echo "Create the database auto-start service." `date`
echo "******************************************************************************"
cp dbora.service /etc/systemd/system/dbora.service
systemctl daemon-reload
systemctl start dbora.service
systemctl enable dbora.service
