Zabbix 3.4 Dell Equallogic
==========================

This template (ZBX3-DELL-EQUALLOGIC) uses the Equallogic-MIB to discover and manage Equallogic Storage Arrays in Zabbix 3.2.

This Zabbix template provides a check of Dell Equallogic systems.
The template has been tested on a several systems: 

* PS4100
* PS6510
* PS5500
* PS6500
* PS-M4110
* PS6110XS
* P6110XV
* PS6110E

Contents
--------

* zbx3-dell-equallogic.xml - Zabbix template

Installation
------------

Import the XML file into Zabbix (Under Configuration -> Templates).

The SNMP Community string for the template can be set in the template configuration itself, under Macros. By default this is set to: "public".

Run the following command on the console:

```
snmpwalk -v2c -c <COMMUNITY-STRING> <EQL-IP> .1.3.6.1.4.1.12740.2.1.1.1.9.1

```

For example:

```
snmpwalk -v2c -c public 123.456.798.1 .1.3.6.1.4.1.12740.2.1.1.1.9.1

```

You will get something like this:

```
SNMPv2-SMI::enterprises.12740.2.1.1.1.9.1.1234567890 = STRING: "Foo"
                                          ----------            -----------
                                          {$EQL_ID}             {$EQL_NAME}
```
If you get multiple results, i.e. if you extended your storage by additional units, you can create multiple
hosts for any discovered subsystem with the same snmp hostname.

Now create/overload a macro on the Host:
```
{$EQL_ID} -> 1234567890
{$EQL_NAME} -> Foo
{$SNMP_COMMUNITY} -> public
```

We need that because zabbix has no nested LLD at the moment, please vote for it https://support.zabbix.com/browse/ZBXNEXT-1527

Value Mappings
--------------

Starting from Zabbix 3.0 these are imported with the XML template. With earlier versions of Zabbix you need to create these manually in the servers administration.

```
eqlControllerBatteryStatus:

1=>ok
2=>failed
3=>good-battery-is-charging
4=>low-voltage-status
5=>low-voltage-is-charging
6=>missing-battery

eqlDiskStatus:

1=>on-line
2=>spare
3=>failed
4=>off-line
5=>alt-sig
6=>too-small
7=>history-of-failures
8=>unsupported-version
9=>unhealthy
10=>replacement
11=>encrypted
12=>notApproved
13=>preempt-failed

eqliscsiVolumeAdminStatus:

1=>online
2=>offline
3=>online-lost-cached-blocks
4=>online-control
5=>offline-control

eqlMemberHealthDetailsFanCurrentState:

0=>unknown
1=>normal
2=>warning
3=>critical

eqlMemberHealthDetailsPowerSupplyCurrentState:

1=>on-and-operating
2=>no-ac-power
3=>failed-or-no-data

eqlMemberHealthDetailsTemperatureCurrentState:

0=>unknown
1=>normal
2=>warning
3=>critical

eqlMemberHealthStatus:

0=>Unknown
1=>Normal
2=>Warning
3=>Critical

eqlMemberRaidStatus:

1=>ok
2=>degraded
3=>verifying
4=>reconstructing
5=>failed
6=>catastrophicLoss
7=>expanding
8=>mirroring
```

Authors
-------

* [The original template](https://www.zabbix.org/wiki/Monitoring_Dell_Equallogic_Systems#Version_1) was created by Ivo van Geel for Radboudumc in Nijmegen.
* [Version 2](https://www.zabbix.org/wiki/Monitoring_Dell_Equallogic_Systems#Version_2) was created by Stefan Krüger.
* [Version 3](https://github.com/asosso/zbx3-dell-equallogic) was created by Andrea Sosso @asosso
* Version 3.2 was extended by Simon @elrido with the volume discovery 


License
-------

The template and the helper script are released under the GNU GPLv3 license. See gpl.txt for more information on the GNU GPLv3 license.
You must include this file when distributing this Zabbix template.

Contribute
----------

Contributions are welcome.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
