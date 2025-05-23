#!/usr/bin/perl
use strict;
use warnings;
use DBD::Oracle qw(:ora_session_modes);

### Variáveis e conexão ao Oracle.
my $oracle_hostname = '192.168.0.104';
my $oracle_database = 'PROD';
my $oracle_port = '1521';
my $oracle_username = 'SYS';
my $oracle_password = 'Nerv2017';
my $oracle_schema = 'SCOTT';

### Quantos SQLs de cada critério (abaixo) você quer analisar?
my $Top = '10';

### Qual o critério de SQLs a serem analisados, e em que ordem?
my @Order = ('ELAPSED_TIME', 'CPU_TIME', 'DISK_READS', 'BUFFER_GETS', 'DIRECT_WRITES', 'SORTS');

my $oracle_dbh = DBI->connect("dbi:Oracle:host=$oracle_hostname;service_name=$oracle_database;port=$oracle_port", $oracle_username, $oracle_password, {RaiseError => 1, AutoCommit => 0, ora_session_mode => ORA_SYSDBA});
$oracle_dbh->{LongReadLen} = 20*1024*1024; # 20MB

open(LOG, '>AutoSQLTUNE.log') || die ("Could not open file!");

### Remover o Tuning Task se ele já existe.
my $task_exist = 0;
my $oracle_sql_01 = "SELECT TASK_ID FROM DBA_ADVISOR_TASKS WHERE OWNER = 'SYS' AND TASK_NAME = 'Portilho Tuning Task'";
my $oracle_sth_01 = $oracle_dbh->prepare($oracle_sql_01);
$oracle_sth_01->execute();
while (my $oracle_ref_01 = $oracle_sth_01->fetchrow_hashref())
	{
	$task_exist++;
	}
$oracle_sth_01->finish();
if ($task_exist > 0)
	{
	my $oracle_sql_02 = "BEGIN DBMS_SQLTUNE.DROP_TUNING_TASK('Portilho Tuning Task'); END;";
	my $oracle_sth_02 = $oracle_dbh->prepare($oracle_sql_02);
	$oracle_sth_02->execute();
	$oracle_sth_02->finish();
	}

foreach (@Order)
	{
	my $Order = $_;
	print "\nAnalisando os TOP $Top SQLs ordenados por $Order...\n\n";
	print LOG "\nAnalisando os $Top 100 SQLs ordenados por $Order...\n\n";

	### Procurar os Top SQL.
	my $oracle_sql_03 = "SELECT SQL_ID, SQL_TEXT FROM (SELECT SQL_ID, SQL_TEXT FROM V\$SQL WHERE PARSING_SCHEMA_NAME = '$oracle_schema' ORDER BY $Order) WHERE ROWNUM < $Top";
	my $oracle_sth_03 = $oracle_dbh->prepare($oracle_sql_03);
	$oracle_sth_03->execute();
	while (my $oracle_ref_03 = $oracle_sth_03->fetchrow_hashref())
		{
		my $sql_id = $oracle_ref_03->{SQL_ID};
		my $sql_text = $oracle_ref_03->{SQL_TEXT};

		### Verificar se o SQL ainda existe mesmo.
		my $sql_exist = 0;
		my $oracle_sql_04 = "SELECT SQL_TEXT FROM V\$SQL WHERE SQL_ID= '$sql_id'";
		my $oracle_sth_04 = $oracle_dbh->prepare($oracle_sql_04);
		$oracle_sth_04->execute();
		while (my $oracle_ref_04 = $oracle_sth_04->fetchrow_hashref())
			{
			$sql_exist++;
			}
		$oracle_sth_04->finish();

		### Executar o Tuning Task
		if ($sql_exist > 0)
			{
			my $oracle_sql_05 = "DECLARE RET_VAL VARCHAR2(4000); BEGIN RET_VAL := DBMS_SQLTUNE.CREATE_TUNING_TASK(SQL_ID => '$sql_id', SCOPE => DBMS_SQLTUNE.SCOPE_COMPREHENSIVE, TIME_LIMIT => 60, TASK_NAME => 'Portilho Tuning Task', DESCRIPTION => 'Portilho Tuning Task'); END;";
			my $oracle_sth_05 = $oracle_dbh->prepare($oracle_sql_05);
			$oracle_sth_05->execute();
			$oracle_sth_05->finish();

			my $oracle_sql_06 = "BEGIN DBMS_SQLTUNE.EXECUTE_TUNING_TASK('Portilho Tuning Task'); END;";
			my $oracle_sth_06 = $oracle_dbh->prepare($oracle_sql_06);
			$oracle_sth_06->execute();
			$oracle_sth_06->finish();

			### Exibição da recomendação.
			my $oracle_sql_07 = "SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK('Portilho Tuning Task') RECOMMENTATION FROM DUAL";
			my $oracle_sth_07 = $oracle_dbh->prepare($oracle_sql_07);
			$oracle_sth_07->execute();
			while (my $oracle_ref_07 = $oracle_sth_07->fetchrow_hashref())
				{
				my $recommendation = $oracle_ref_07->{RECOMMENTATION};
				print "$recommendation\n\n";
				print LOG "$recommendation\n\n";
				}

			### Execução da recomendação.
			my $oracle_sql_08 = "SELECT DBMS_SQLTUNE.SCRIPT_TUNING_TASK('Portilho Tuning Task') RECOMMENTATION FROM DUAL";
			my $oracle_sth_08 = $oracle_dbh->prepare($oracle_sql_08);
			$oracle_sth_08->execute();
			while (my $oracle_ref_08 = $oracle_sth_08->fetchrow_hashref())
				{
				my $recommendation = $oracle_ref_08->{RECOMMENTATION};
				if ($recommendation !~ m/There are no recommended actions for this task under the given filters./)
					{
					my @CompleteRecommendation =  split /\n/, $recommendation;
					foreach (@CompleteRecommendation)
						{
						my $RecommendationLine = $_;
						unless ($RecommendationLine =~ /;/gm) {next;}

						if ($RecommendationLine =~ /^create index /) {$RecommendationLine =~ s/;//;}
						if ($RecommendationLine =~ /^execute /) {$RecommendationLine =~ s/execute //; $RecommendationLine = "BEGIN $RecommendationLine END;";}
						my $oracle_sql_09 = "$RecommendationLine";
						my $oracle_sth_09 = $oracle_dbh->prepare($oracle_sql_09);
						print "Recommendation to implement: $RecommendationLine\n\n";
						print LOG "Recommendation to implement:: $RecommendationLine\n\n";

						print "Do you wish to implement it? (Y/N)";
						my $YesOrNo = <STDIN>;
						chomp $YesOrNo;
						if ($YesOrNo eq 'Y')
							{
							$oracle_sth_09->execute();
							$oracle_sth_09->finish();
							print "Recommendation IMPLEMENTED.\n\n";
							print LOG "Recommendation IMPLEMENTED.\n\n";
							last;
							}
						elsif ($YesOrNo eq 'N')
							{
							print "Recommendation NOT IMPLEMENTED.\n\n";
							print LOG "Recommendation NOT IMPLEMENTED.\n\n";
							last;
							}
						else
							{
							print "\nWell, I don´t know what to do...\n";
							print LOG "\nWell, I don´t know what to do...\n";
							}
						}
					}
				print "\n\n\n\n\n";
				}
			$oracle_sth_08->finish();

			my $oracle_sql_10 = "BEGIN DBMS_SQLTUNE.DROP_TUNING_TASK('Portilho Tuning Task'); END;";
			my $oracle_sth_10 = $oracle_dbh->prepare($oracle_sql_10);
			$oracle_sth_10->execute();
			$oracle_sth_10->finish();
			}
		}
	$oracle_sth_03->finish();
	}
$oracle_dbh->disconnect;
exit;
