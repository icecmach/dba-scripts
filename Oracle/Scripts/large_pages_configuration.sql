/*
Désactiver le Transparent HugePages

Modifier le fichier « /etc/default/grub » et ajouter le paramètre « transparent_hugepage=never »
Exécuter le commande “grub2–mkconfig” pour recréer le fichier grub.cfg.
GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet numa=off transparent_hugepage=never"
grub2-mkconfig -o /boot/grub2/grub.cfg


Fixer memlock user limit sur etc/security/limits.d/oracle-database-preinstall-18c.conf

Cette valeur (en kilobyte [kB]) est correspondante à 90% de la total RAM (99006144).
oracle   hard   memlock    89105529
oracle   soft   memlock    89105529

Reconnecter avec le compte oracle et vérifier le limite memlock
ulimit -l


Fixer vm.nr_hugepages sur /etc/sysctl.conf
HugePages = (Somme le SGA_TARGET de tous les instances) / HugePagesize
HugePages = (60 GB * 1024 MB) / 2MB
= 61440 MB / 2 MB
= 30720

Arrêter les listeners
lsnrctl stop LISTENER_dbname

Prendre un backup du fichier spfile et créer un pfile
cd $ORACLE_HOME/dbs
cp spfiledbname.ora spfiledbname_Backup.ora
create pfile='initdbnameBeforeHugePages.ora' from spfile;

Arrêter les bases de donnes
dbname shutdown immediate;

Redémarrer le serveur / startup nomount
dbname startup nomount;

Oracle recommande initialement d’utilise 20% de la mémoire disponible pour la PGA et 80% pour la SGA.
Nous utiliserons les méthodes de gestion de mémoire suivantes:
Automatic shared memory management – pour la SGA
Automatic PGA memory management – pour la PGA
*/

-- Désactiver Automatic Memory Management (AMM) qui n’est pas compatible avec HugePages
alter system set MEMORY_TARGET = 0 scope = SPFILE;
alter system set MEMORY_MAX_TARGET = 0 scope = SPFILE;

-- Activer Automatic Shared Memory Management ASMM et fixer les valeurs pour SGA.
alter system set SGA_TARGET = 60G scope = SPFILE;
alter system set SGA_MAX_SIZE = 60G scope = SPFILE;

-- Les composants ci-dessous sont gères automatiquement par le SGA. Nous pouvons définir une valeur minimale.
alter system set SHARED_POOL_SIZE = 4G scope = SPFILE;
alter system set SHARED_POOL_RESERVED_SIZE = 210M scope = SPFILE;
alter system set LARGE_POOL_SIZE = 100M scope = SPFILE;
alter system set JAVA_POOL_SIZE = 200M scope = SPFILE;
alter system set DB_CACHE_SIZE = 15G scope = SPFILE;
alter system set STREAMS_POOL_SIZE = 70M scope = SPFILE;

-- Ces composants prendraient leur mémoire du SGA_TARGET s'ils sont fixés
alter system set LOG_BUFFER = 64M scope = SPFILE;
alter system set DB_KEEP_CACHE_SIZE = 0 scope = SPFILE;
alter system set DB_RECYCLE_CACHE_SIZE = 0 scope = SPFILE;
alter system set db_2k_cache_size = 0 scope = SPFILE;
alter system set db_32k_cache_size = 0 scope = SPFILE;
alter system set db_4k_cache_size = 0 scope = SPFILE;
alter system set db_8k_cache_size = 0 scope = SPFILE;

-- Fixer les valeurs PGA.
alter system set PGA_AGGREGATE_TARGET = 8G scope = SPFILE;
alter system set PGA_AGGREGATE_LIMIT = 16G scope = SPFILE;

-- Activer le HugePages
alter system set USE_LARGE_PAGES = ONLY scope = SPFILE;

-- Redémarrer les bases de donnes
dbname shutdown;
startup nomount;
alter database mount;
alter database open;

/*
Vérifier le fichier alert.log

Après les configurations vérifier le fichier log:
/u01/app/oracle/product/diag/rdbms/dbname/dbname/trace/alert_dbname.log

Il doit avoir un message similaire comme ci-dessous:

Supported system pagesize(s):
2023-04-27T15:18:31.192974-04:00
  PAGESIZE  AVAILABLE_PAGES  EXPECTED_PAGES  ALLOCATED_PAGES  ERROR(s)
2023-04-27T15:18:31.193101-04:00
  2048K             1610            1602            1602        NONE

Démarrer les listeners
lsnrctl start LISTENER_dbname
*/
