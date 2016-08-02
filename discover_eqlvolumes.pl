#!/usr/bin/perl

use warnings;
use strict;

if (@ARGV != 2) {
	print "\nUsage: $0 <SANGroup hostname> <SAN Community>\n\n";
	exit 1;
}
 
my $HOSTNAME="${ARGV[0]}";
my $SNMP_COMMUNITY="${ARGV[1]}";
my $SNMP_EQLISCSIVOLUMENAME=".1.3.6.1.4.1.12740.5.1.7.1.1.4";
my $SNMP_EQLISCSIVOLUMEADMINSTATUS=".1.3.6.1.4.1.12740.5.1.7.1.1.9";

my @snmp_output=qx(snmpwalk -On -t 2 -r 2 -v 2c -c ${SNMP_COMMUNITY} ${HOSTNAME} ${SNMP_EQLISCSIVOLUMENAME} 2>/dev/null);
if ($? != 0) {
	print STDERR "Could not run SNMP query on host ${HOSTNAME}!\n";
	exit 1;
}

my @snmp_volume_status=qx(snmpwalk -On -t 2 -r 2 -v 2c -c ${SNMP_COMMUNITY} ${HOSTNAME} ${SNMP_EQLISCSIVOLUMEADMINSTATUS} 2>/dev/null);
if ($? != 0) {
        print STDERR "Could not run SNMP query on host ${HOSTNAME}!\n";
        exit 1;
}

my %status_hash=();
foreach my $line (@snmp_volume_status) {
	# .1.3.6.1.4.1.12740.5.1.7.1.1.9.1161504381.1 = INTEGER: 4
	$line =~ /\s*([.0-9]+)[^:]+:\s*(.+)/;

	if (!defined $1 || !defined $2 || $2 eq 0) {
		print STDERR "Could not read Volume Status!\n";
		exit 1;
	}

	my $oid="$1";
	my $volumestatus="$2";

	$oid =~ s/${SNMP_EQLISCSIVOLUMEADMINSTATUS}\.//;

	$status_hash{$oid} = $volumestatus;
}

print "{\n";
print "\t\"data\":[\n\n";

my @snmp_indexes=();
my @snmp_values=();
foreach my $line (@snmp_output) {
	# .1.3.6.1.4.1.12740.5.1.7.1.1.4.2030877825.199 = STRING: "SSAN-UMCFSCL02-STFILE-01-S-SBHRM"
	$line =~ /\s*([.0-9]+)[^"]+"(.+)"/;

	if (!defined $1 || !defined $2) {
		print STDERR "Could not read Volume Name!\n";
		exit 1;
	}

	my $oid="$1";
	my $volumename="$2";

	$oid =~ s/${SNMP_EQLISCSIVOLUMENAME}\.//;

	if (!defined $status_hash{$oid}) {
		print STDERR "Could not find status for OID $oid!\n";
		exit 1;
	}
	my $volumestatus = $status_hash{$oid};

	# Status should be one of:
	# 1: online
	# 2: offline
	# 3: online-lost-cached-blocks
	#
	# Do not add control volumes:
	# 4: online-control
	# 5: offline-control
	if ($volumestatus eq 1 || $volumestatus eq 2 || $volumestatus eq 3) {
		push (@snmp_indexes, "$oid");
		push (@snmp_values, "$volumename");
	}
}

my $i=0;
while ($i <= $#snmp_indexes) {
	if ($i != 0) {
		print "\t,\n";
	}
 
	print "\t{\n";
	print "\t\t\"{#SNMPINDEX}\":\"$snmp_indexes[$i]\",\n";
	print "\t\t\"{#SNMPVALUE}\":\"$snmp_values[$i]\"\n";
	print "\t}\n";

	$i++;
}
 
print "\n\t]\n";
print "}\n";

