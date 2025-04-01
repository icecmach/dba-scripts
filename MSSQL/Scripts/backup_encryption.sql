/*
Backup Encryption
To enable Backup Encryption, follow these steps:

- Create a Service Master Key (SMK): The SMK is automatically generated and stored in the system master
  database when you install SQL Server. It’s used to encrypt the Database Master Key (DMK).
- Create a Database Master Key (DMK): The DMK is unique to each system master database and is used to protect
  the certificate or asymmetric key. The database master key is a symmetric key used to protect the private keys of
  certificates and asymmetric keys that are present in the database and secrets in database scoped credentials.
- Create a Certificate or Asymmetric Key: Choose a certificate or asymmetric key to use for encryption.
  You can create a new one or use an existing one.
- Specify Encryption Algorithm and Encryptor: Choose an encryption algorithm (e.g., AES_256) and an encryptor
  (e.g., certificate) when creating a backup.
- Enable Backup Encryption: Select the “Backup Encryption” option in the Backup Options page or use the BACKUP
  statement with the ENCRYPTION option.

Best Practices
- Store backup encryption certificates and keys securely
- Limit access to backup files and storage locations
- Regularly test and verify backup restore processes
- Consider storing backup encryption certificates and keys in an off-site location for disaster recovery scenarios

Prerequisites
- Storage for the encrypted backup. Depending on which option you choose, one of:
- A local disk or to storage with adequate space to create a backup of the database.
- An Azure Storage account and a container. For more information, see Create a storage account.
- A database master key (DMK) for the master database, and a certificate or asymmetric key on the instance of SQL Server.
  For encryption requirements and permissions
*/


/*
#================================================================
# Create Section
#================================================================
*/
--
-- Check existing keys
--
SELECT * FROM master.sys.symmetric_keys

--
-- Create DMK (database master key)
--
USE master;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'pass1';
GO

--
-- Check existing certificates
--
SELECT * FROM sys.certificates;

--
-- Create certificate
--
Use master;
GO
CREATE CERTIFICATE MyTestDBBackupEncryptCert
    WITH SUBJECT = 'MyTestDB Backup Encryption Certificate';
GO


/*
#================================================================
# Backup Section
#================================================================
*/
--
-- Backup of the service master key.
--
USE master;
GO
BACKUP SERVICE MASTER KEY TO FILE = 'c:\Temp\service_master_key'
    ENCRYPTION BY PASSWORD = 'pass2';
GO

--
-- Backup of the master key.
--
USE master;
GO
BACKUP MASTER KEY TO FILE = 'c:\Temp\database_master_key'
    ENCRYPTION BY PASSWORD = 'pass3';
GO

--
-- Backup of the certificate
--
BACKUP CERTIFICATE MyTestDBBackupEncryptCert
  TO FILE = 'c:\Temp\MyTestDBBackupEncryptCert.cer'
  WITH PRIVATE KEY(
    FILE = 'c:\Temp\MyTestDBBackupEncryptCert.key',
    ENCRYPTION BY PASSWORD = 'pass4');
GO

--
-- Backup database
--
BACKUP DATABASE [MyTestDB]
TO DISK = N'c:\Temp\MyTestDB.bak'
WITH
COMPRESSION,
ENCRYPTION (
    ALGORITHM = AES_256,
    SERVER CERTIFICATE = MyTestDBBackupEncryptCert
),
STATS = 10;
GO

--
-- Backup database with Ola script
--
EXECUTE dbo.DatabaseBackup @Databases = 'USER_DATABASES',
@Directory = 'C:\Temp',
@BackupType = 'FULL',
@Compress = 'Y',
@Encrypt = 'Y',
@EncryptionAlgorithm = 'AES_256',
@ServerCertificate = 'MyTestDBBackupEncryptCert'


/*
#================================================================
# Restore Section
#================================================================
*/

-- Restores the database master key
/* USE master;
GO
RESTORE MASTER KEY
    FROM FILE = 'c:\Temp\database_master_key'
    DECRYPTION BY PASSWORD = 'pass3'
    ENCRYPTION BY PASSWORD = 'pass1';
GO

-- Because this master key is not encrypted by the service master key, a password must be specified when it is opened.
USE master;
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'pass1';
*/


--Database master key passwords do not need to match between instances
--When you backed up the certificate you added a private key and password, this private key is independent of the existing database master key.
--This certificate can now be created using the .cert, .key, and private key password on any other instance that has a database master key (as long as the service account has permissions)

-- Availability Group database backups are typically performed on the preferred backup replica.
-- If you restore a backup on a replica other than where the backup was taken from, ensure that the original certificate used for backup
-- is available on the replica you're restoring to.

-- Only the certificate is needed to perform the restore
-- Restore the certificate
CREATE CERTIFICATE MyTestDBBackupEncryptCert
    FROM FILE = 'c:\Temp\MyTestDBBackupEncryptCert.cer'
    WITH PRIVATE KEY (FILE = 'c:\Temp\MyTestDBBackupEncryptCert.key',
    DECRYPTION BY PASSWORD = 'pass4');
GO
