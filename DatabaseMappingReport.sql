/*======================================================================================= 
    Name: DatabaseMappingReport.sql
    Author: Alex McAnnally  Last Edited: August 22, 2018
 
    Purpose: Provide necessary table, column, primary key index info for Staticians
        - 
     
    Notes: 
     
=======================================================================================*/
USE 
Database_Name_Here
GO;

--Database Report
select  t.name as TableName,
		i.rows as [RowCount],
		c.name as ColumnName,
		Ty.Name as ColumnDataType,
		C.is_nullable as IsNullable
		--idx.is_primary_key as IsPrimaryKey
from sys.tables t
	join sys.columns c on t.object_id = c.object_id
	join sys.types ty on c.system_type_id = ty.system_type_id
	join sys.sysindexes i ON t.OBJECT_ID = i.ID 
where t.is_ms_shipped = 0
and indid IN (0,1)
and i.rows <> 0
order by t.name

--List of all Primary Keys in all database Tables + some general info
SELECT 
    so.name 'Table Name',
    c.name 'Column Name',
    t.Name 'Data type',
    c.max_length 'Max Length',
    ISNULL(i.is_primary_key, 0) 'Primary Key'
FROM    
    sys.columns c
INNER JOIN 
    sys.types t ON c.user_type_id = t.user_type_id
LEFT OUTER JOIN 
    sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
LEFT OUTER JOIN 
    sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
INNER JOIN 
    sysobjects so ON c.object_id = so.id
WHERE
    i.is_primary_key = 1 and 
    so.xtype = 'U'
Order By 'Table Name', 'Column Name'

