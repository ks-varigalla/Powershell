<#
    .SYNOPSIS
        Get the status of the Availability Groups on the servers.
 
    .DESCRIPTION
        Displays the status for availability groups on the servers
        Displays the status for availability groups replicas on the servers
        Displays the database status in every availability group on the servers
#>

# Place the list of servers here

$servers = Get-Content -Path "D:\DBReports\AG_Servers.txt"

$attach = "D:\DBReports\AG_Status_Report.xlsx"

# Deleting the old output file

if(Test-Path -Path $attach){
    
    Remove-Item -Path $attach -Force

}

# Get-AvailabilityGroupStatus

$query1 = "

            IF SERVERPROPERTY(N'IsHadrEnabled') = 1
            BEGIN
                DECLARE @cluster_name NVARCHAR(128)
                DECLARE @quorum_type VARCHAR(50)
                DECLARE @quorum_state VARCHAR(50)
                DECLARE @Healthy INT
                DECLARE @Primary sysname
 
                SELECT @cluster_name = cluster_name ,
                        @quorum_type = quorum_type_desc ,
                        @quorum_state = quorum_state_desc
                FROM   sys.dm_hadr_cluster
 
                SELECT @Healthy = COUNT(*) 
                FROM master.sys.dm_hadr_availability_replica_states 
                WHERE recovery_health_desc <> 'ONLINE'
                    OR synchronization_health_desc <> 'HEALTHY'
 
                SELECT @primary = r.replica_server_name
                FROM master.sys.dm_hadr_availability_replica_states s
                    INNER JOIN master.sys.availability_replicas r ON s.replica_id = r.replica_id
                WHERE role_desc = 'PRIMARY'
 
                IF @Primary IS NULL 
                    SELECT ISNULL(@cluster_name, '') AS [ClusterName] ,
                            ag.name,
                        CAST(SERVERPROPERTY(N'Servername') AS sysname) AS [Name] ,
                        --ISNULL(@Primary, '') AS PrimaryServer , --OldLine
			            s.role_desc AS [AGRole], --NewLine
                        @quorum_type AS [ClusterQuorumType] ,
                        @quorum_state AS [ClusterQuorumState] ,
                        CAST(ISNULL(SERVERPROPERTY(N'instancename'), N'') AS sysname) AS [InstanceName] ,
                        CASE @Healthy
                                WHEN 0 THEN 'Healthy'
                                ELSE 'Unhealthly'
                        END AS AvailavaiblityGroupState
                    FROM MASTER.sys.availability_groups ag  
                        INNER JOIN master.sys.dm_hadr_availability_replica_states s ON AG.group_id = s.group_id
                        INNER JOIN master.sys.availability_replicas r ON s.replica_id = r.replica_id
                ELSE
                    SELECT ISNULL(@cluster_name, '') AS [ClusterName] ,
                            ag.name,
                        CAST(SERVERPROPERTY(N'Servername') AS sysname) AS [Name] ,
                        --ISNULL(@Primary, '') AS PrimaryServer , --OldLine
			            s.role_desc AS [AGRole], --NewLine
                        @quorum_type AS [ClusterQuorumType] ,
                        @quorum_state AS [ClusterQuorumState] ,
                        CAST(ISNULL(SERVERPROPERTY(N'instancename'), N'') AS sysname) AS [InstanceName] ,
                        CASE @Healthy
                                WHEN 0 THEN 'Healthy'
                                ELSE 'Unhealthly'
                        END AS AvailavaiblityGroupState
                    FROM MASTER.sys.availability_groups ag  
                        INNER JOIN master.sys.dm_hadr_availability_replica_states s ON AG.group_id = s.group_id
                        INNER JOIN master.sys.availability_replicas r ON s.replica_id = r.replica_id
                    WHERE s.role_desc = 'PRIMARY'
            END"

# Get-SqlAvailabilityReplicaStatus

 $query2 = "
            IF SERVERPROPERTY(N'IsHadrEnabled') = 1
            BEGIN
                SELECT   arrc.replica_server_name ,
                         COUNT(cm.member_name) AS node_count ,
                         cm.member_state_desc AS member_state_desc ,
                         SUM(cm.number_of_quorum_votes) AS quorum_vote_sum
                INTO     #tmpar_availability_replica_cluster_info
                FROM     (   SELECT DISTINCT replica_server_name ,
                                    node_name
                             FROM   master.sys.dm_hadr_availability_replica_cluster_nodes
                         ) AS arrc
                         LEFT OUTER JOIN master.sys.dm_hadr_cluster_members AS cm ON UPPER(arrc.node_name) = UPPER(cm.member_name)
                GROUP BY arrc.replica_server_name,
                    cm.member_state_desc;
 
                SELECT *
                INTO   #tmpar_ags
                FROM   master.sys.dm_hadr_availability_group_states
                SELECT ar.group_id ,
                       ar.replica_id ,
                       ar.replica_server_name ,
                       ar.availability_mode ,
                       ( CASE WHEN UPPER(ags.primary_replica) = UPPER(ar.replica_server_name) THEN
                                  1
                              ELSE 0
                         END
                       ) AS role ,
                       ars.synchronization_health
                INTO   #tmpar_availabilty_mode
                FROM   master.sys.availability_replicas AS ar
                       LEFT JOIN #tmpar_ags AS ags ON ags.group_id = ar.group_id
                       LEFT JOIN master.sys.dm_hadr_availability_replica_states AS ars ON ar.group_id = ars.group_id
                                                                              AND ar.replica_id = ars.replica_id
 
                SELECT am1.replica_id ,
                       am1.role ,
                       ( CASE WHEN ( am1.synchronization_health IS NULL ) THEN 3
                              ELSE am1.synchronization_health
                         END
                       ) AS sync_state ,
                       ( CASE WHEN ( am1.availability_mode IS NULL )
                                   OR ( am3.availability_mode IS NULL ) THEN NULL
                              WHEN ( am1.role = 1 ) THEN 1
                              WHEN (   am1.availability_mode = 0
                                       OR am3.availability_mode = 0
                                   ) THEN 0
                              ELSE 1
                         END
                       ) AS effective_availability_mode
                INTO   #tmpar_replica_rollupstate
                FROM   #tmpar_availabilty_mode AS am1
                       LEFT JOIN (   SELECT group_id ,
                                            role ,
                                            availability_mode
                                     FROM   #tmpar_availabilty_mode AS am2
                                     WHERE  am2.role = 1
                                 ) AS am3 ON am1.group_id = am3.group_id
 
                SELECT   AR.replica_server_name AS [Name] ,
                         AR.availability_mode_desc AS [AvailabilityMode] ,
                         AR.backup_priority AS [BackupPriority] ,
                         AR.primary_role_allow_connections_desc AS [ConnectionModeInPrimaryRole] ,
                         AR.secondary_role_allow_connections_desc AS [ConnectionModeInSecondaryRole] ,
                         arstates.connected_state_desc AS [ConnectionState] ,
                         ISNULL(AR.create_date, 0) AS [CreateDate] ,
                         ISNULL(AR.modify_date, 0) AS [DateLastModified] ,
                         ISNULL(AR.endpoint_url, N'''') AS [EndpointUrl] ,
                         AR.failover_mode AS [FailoverMode] ,
                         arcs.join_state_desc AS [JoinState] ,
                         ISNULL(arstates.last_connect_error_description, N'') AS [LastConnectErrorDescription] ,
                         ISNULL(arstates.last_connect_error_number, '') AS [LastConnectErrorNumber] ,
                         ISNULL(arstates.last_connect_error_timestamp, '') AS [LastConnectErrorTimestamp] ,
                         member_state_desc AS [MemberState] ,
                         arstates.operational_state_desc AS [OperationalState] ,
                         SUSER_SNAME(AR.owner_sid) AS [Owner] ,
                         ISNULL(arci.quorum_vote_sum, -1) AS [QuorumVoteCount] ,
                         ISNULL(AR.read_only_routing_url, '') AS [ReadonlyRoutingConnectionUrl] ,
                         arstates.role_desc AS [Role] ,
                         arstates.recovery_health_desc AS [RollupRecoveryState] ,
                         ISNULL(AR.session_timeout, -1) AS [SessionTimeout] ,
                         ISNULL(AR.seeding_mode, 1) AS [SeedingMode]
                FROM     master.sys.availability_groups AS AG
                         INNER JOIN master.sys.availability_replicas AS AR ON ( AR.replica_server_name IS NOT NULL )
                                                                          AND ( AR.group_id = AG.group_id )
                         LEFT OUTER JOIN master.sys.dm_hadr_availability_replica_states AS arstates ON AR.replica_id = arstates.replica_id
                         LEFT OUTER JOIN master.sys.dm_hadr_availability_replica_cluster_states AS arcs ON AR.replica_id = arcs.replica_id
                         LEFT OUTER JOIN #tmpar_availability_replica_cluster_info AS arci ON UPPER(AR.replica_server_name) = UPPER(arci.replica_server_name)
                         LEFT OUTER JOIN #tmpar_replica_rollupstate AS arrollupstates ON AR.replica_id = arrollupstates.replica_id
                         Where AR.replica_server_name=@@servername --NewLine
                ORDER BY [Name] ASC
 
                DROP TABLE #tmpar_availabilty_mode
                DROP TABLE #tmpar_ags
                DROP TABLE #tmpar_availability_replica_cluster_info
                DROP TABLE #tmpar_replica_rollupstate
            END"


# Get-SqlDatabaseReplicaStatus

$query3 = "
                IF SERVERPROPERTY(N'IsHadrEnabled') = 1
                BEGIN
                    SELECT ars.role ,
                        drs.database_id ,
                        drs.replica_id ,
                        drs.last_commit_time
                    INTO   #tmpdbr_database_replica_states_primary_LCT
                    FROM   master.sys.dm_hadr_database_replica_states AS drs
                        LEFT JOIN master.sys.dm_hadr_availability_replica_states ars ON drs.replica_id = ars.replica_id
                    WHERE  ars.role = 1
    
                    SELECT   AR.replica_server_name AS [AvailabilityReplicaServerName] ,
                            dbcs.database_name AS [AvailabilityDatabaseName] ,
                            AG.name AS [AvailabilityGroupName] ,
                            ISNULL(dbr.database_id, 0) AS [DatabaseId] ,
                            CASE dbcs.is_failover_ready
                                WHEN 1 THEN 0
                                ELSE
                                    ISNULL(
                                                DATEDIFF(
                                                            ss ,
                                                            dbr.last_commit_time,
                                                            dbrp.last_commit_time
                                                        ) ,
                                                0
                                            )
                            END AS [EstimatedDataLoss] ,
                            ISNULL(   CASE dbr.redo_rate
                                            WHEN 0 THEN -1
                                            ELSE CAST(dbr.redo_queue_size AS FLOAT) / dbr.redo_rate
                                    END ,
                                    -1
                                ) AS [EstimatedRecoveryTime] ,
                            ISNULL(dbr.filestream_send_rate, -1) AS [FileStreamSendRate] ,
                            ISNULL(dbcs.is_failover_ready, 0) AS [IsFailoverReady] ,
                            ISNULL(dbcs.is_database_joined, 0) AS [IsJoined] ,
                            arstates.is_local AS [IsLocal] ,
                            ISNULL(dbr.is_suspended, 0) AS [IsSuspended] ,
                            ISNULL(dbr.last_commit_time, 0) AS [LastCommitTime] ,
                            ISNULL(dbr.last_hardened_time, 0) AS [LastHardenedTime] ,
                            ISNULL(dbr.last_received_time, 0) AS [LastReceivedTime] ,
                            ISNULL(dbr.last_redone_time, 0) AS [LastRedoneTime] ,
                            ISNULL(dbr.last_sent_time, 0) AS [LastSentTime] ,
                            ISNULL(dbr.log_send_queue_size, -1) AS [LogSendQueueSize] ,
                            ISNULL(dbr.log_send_rate, -1) AS [LogSendRate] ,
                            ISNULL(dbr.redo_queue_size, -1) AS [RedoQueueSize] ,
                            ISNULL(dbr.redo_rate, -1) AS [RedoRate] ,
                            ISNULL(AR.availability_mode, 2) AS [ReplicaAvailabilityMode] ,
                            arstates.role_desc AS [ReplicaRole] ,
                            dbr.suspend_reason_desc AS [SuspendReason] ,
                            ISNULL(
                                    CASE dbr.log_send_rate
                                            WHEN 0 THEN -1
                                            ELSE
                                                CAST(dbr.log_send_queue_size AS FLOAT)
                                                / dbr.log_send_rate
                                    END ,
                                    -1
                                ) AS [SynchronizationPerformance] ,
                            dbr.synchronization_state_desc AS [SynchronizationState]
                    FROM     master.sys.availability_groups AS AG
                            INNER JOIN master.sys.availability_replicas AS AR ON AR.group_id = AG.group_id
                            INNER JOIN master.sys.dm_hadr_database_replica_cluster_states AS dbcs ON dbcs.replica_id = AR.replica_id
                            LEFT OUTER JOIN master.sys.dm_hadr_database_replica_states AS dbr ON dbcs.replica_id = dbr.replica_id
                                                                                    AND dbcs.group_database_id = dbr.group_database_id
                            LEFT OUTER JOIN #tmpdbr_database_replica_states_primary_LCT AS dbrp ON dbr.database_id = dbrp.database_id
                            INNER JOIN master.sys.dm_hadr_availability_replica_states AS arstates ON arstates.replica_id = AR.replica_id
                    Where AR.replica_server_name=@@servername --NewLine
                    ORDER BY [AvailabilityReplicaServerName] ASC ,
                            [AvailabilityDatabaseName] ASC;
 
                    DROP TABLE #tmpdbr_database_replica_states_primary_LCT
                END"

        

# Run the query against each server specified .txt file

foreach($server in $servers){

    $output1 = Invoke-Sqlcmd -ServerInstance $server -Query $query1 

    $output1 | Select ClusterName, @{n="Node_Name";e={$_.Name}}, @{n="AG_role";e={$_.AGRole}}, ClusterQuorumType, ClusterQuorumState, AvailavaiblityGroupState |
    Export-Excel "D:\DBReports\AG_Status_Report.xlsx" -WorksheetName "AvailabilityGroup_ClusterInfo" -AutoSize -AutoFilter -BoldTopRow -Append

    $output2 = Invoke-Sqlcmd -ServerInstance $server -Query $query2

    $output2 | Select Name, Role, AvailabilityMode, BackupPriority, ConnectionState, MemberState, OperationalState, Owner |
    Export-Excel "D:\DBReports\AG_Status_Report.xlsx" -WorksheetName "AvailabilityReplicaStatus" -AutoSize -AutoFilter -BoldTopRow -Append

    $output3 = Invoke-Sqlcmd -ServerInstance $server -Query $query3 

    $output3 | Select  @{n="AvailabilityGroup_Name";e={$_.AvailabilityGroupName}}, @{n="AG_InstanceName";e={$_.AvailabilityReplicaServerName}}, @{n="AG_DatabaseName";e={$_.AvailabilityDatabaseName}}, ReplicaRole, SynchronizationState  |
    Export-Excel "D:\DBReports\AG_Status_Report.xlsx" -WorksheetName "DatabaseReplicaStatus" -AutoSize -AutoFilter -BoldTopRow -Append

}

# Sending an email notification

$from = "Autoscript@primark.ie"

$to = "jaganathanr@hcl.com"

$subject = "SQL Server Availability Group Reports"

Send-MailMessage -SmtpServer smtp.primark.ie -From $from -To $to -Subject $subject -Attachments $attach

