# T-SQL Database Report

This repository contains a T-SQL script, `DatabaseMappingReport.sql`, that generates a structural report of a SQL Server database. It provides a quick overview of tables, columns, row counts, and primary keys, making it especially useful for analysts, statisticians, and data engineers working with unfamiliar databases.

## Features

- Lists all user tables with:
  - Table name
  - Row count (non-empty tables)
  - Column name
  - Column data type
  - Nullability

- Lists all primary key columns with:
  - Table name
  - Column name
  - Data type
  - Max length
  - Primary key indicator

- Excludes system tables
- Outputs two clean result sets for documentation or export

## Requirements

- Microsoft SQL Server
- Read access to the catalog views:
  - sys.tables
  - sys.columns
  - sys.types
  - sys.indexes
  - sys.index_columns
  - sys.sysindexes
  - sysobjects

## Usage

1. **Open the script**  
   Open `DatabaseMappingReport.sql` in SQL Server Management Studio (SSMS) or your preferred SQL client.

2. **Specify the database**  
   Replace the placeholder with the database you want to analyze:

   ```sql
   USE Database_Name_Here;
   GO;
   ```

3. **Run the script**  
   Execute the script to generate two result sets:
   - Database structure report
   - Primary key report

4. **Export results (optional)**  
   You can export each result set to CSV or Excel for documentation or sharing.

## Output Details

### 1. Database Structure Report

This section returns a list of all non-empty user tables with their columns and metadata.

**Columns returned:**
- TableName
- RowCount
- ColumnName
- ColumnDataType
- IsNullable

**Query excerpt:**

```sql
select  t.name as TableName,
        i.rows as [RowCount],
        c.name as ColumnName,
        Ty.Name as ColumnDataType,
        C.is_nullable as IsNullable
from sys.tables t
    join sys.columns c on t.object_id = c.object_id
    join sys.types ty on c.system_type_id = ty.system_type_id
    join sys.sysindexes i ON t.OBJECT_ID = i.ID
where t.is_ms_shipped = 0
  and indid IN (0,1)
  and i.rows <> 0
order by t.name;
```

### 2. Primary Key Report

This section returns all primary key columns for user tables.

**Columns returned:**
- Table Name
- Column Name
- Data Type
- Max Length
- Primary Key

**Query excerpt:**

```sql
SELECT 
    so.name 'Table Name',
    c.name 'Column Name',
    t.Name 'Data type',
    c.max_length 'Max Length',
    ISNULL(i.is_primary_key, 0) 'Primary Key'
FROM sys.columns c
INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
LEFT OUTER JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
LEFT OUTER JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
INNER JOIN sysobjects so ON c.object_id = so.id
WHERE i.is_primary_key = 1
  AND so.xtype = 'U'
ORDER BY 'Table Name', 'Column Name';
```

## Notes & Limitations

- Uses `sys.sysindexes`, which is deprecated but still widely supported.
- Only includes tables with at least one row (due to `i.rows <> 0`).
- Only returns user tables (`xtype = 'U'`).
- Not intended to replace full data modeling tools; meant for fast exploration and documentation.

## Use Cases

- Generating a quick data dictionary
- Getting oriented with a legacy database
- Supporting ETL or reporting requirements
- Identifying primary keys for joins or modeling

## Author

**Alex McAnnally**  
Last Edited: August 22, 2018
