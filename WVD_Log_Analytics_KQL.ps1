#What data is being collected?
Perf
| summarize by ObjectName, CounterName

#Windows failed logins 
#Find reports of Windows accounts that failed to login. 
SecurityEvent
| where EventID == 4625
| summarize count() by TargetAccount // count the reported security events for each account

#CPU, memory, disk, network usage per host
Perf
| where ObjectName == "LogicalDisk" and CounterName == "% Free Space"
| where InstanceName <> "_Total"
| summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 10m), Computer, InstanceName

Perf
| where ObjectName == "Processor" and CounterName == "% Processor Time"
| summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 10m), Computer, InstanceName

Perf
| where ObjectName == "Memory" and CounterName == "% Committed Bytes In Use"
| summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 10m), Computer, InstanceName

Perf
| where ObjectName == "Network Interface"
| summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 10m), Computer, InstanceName, CounterName

#Current active sessions
Perf
| where ObjectName == "Terminal Services"
| where CounterName == "Active Sessions"
| summarize arg_max(TimeGenerated, *) by Computer
| project Computer, CounterName, CounterValue

#Current disconnected sessions
Perf
| where ObjectName == "Terminal Services"
| where CounterName == "Inactive Sessions"
| summarize arg_max(TimeGenerated, *) by Computer
| project Computer, CounterName, CounterValue

#Current total sessions
Perf
| where ObjectName == "Terminal Services" 
| where CounterName == "Total Sessions" 
| summarize arg_max(TimeGenerated, *) by Computer
| project Computer, CounterName, CounterValue

#Average and maximum sessions
Perf
| where ObjectName == "Terminal Services"
| where CounterName == "Total Sessions"
| summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 1h), Computer

Perf
| where ObjectName == "Terminal Services"
| where CounterName == "Total Sessions"
| summarize AggregatedValue = max(CounterValue) by bin(TimeGenerated, 1h), Computer

