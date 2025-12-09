/*======================================================================================= 
    Name: DatabaseMappingReport.sql
    Author: Alex McAnnally   
	Last Edited: 12/9/2025
 
    Purpose: Provide necessary table, column, primary key, and general metadata info 
             for statisticians.
=======================================================================================*/

USE Database_Name_Here;
GO

/*===============================================================================
  1) Main table/column report with row counts and key column flags
===============================================================================*/

;WITH RowCounts AS (
    SELECT 
        p.object_id,
        TotalRows = SUM(p.rows)
    FROM sys.partitions p
    WHERE p.index_id IN (0, 1)   -- heap or clustered index
    GROUP BY p.object_id
),
PrimaryKeyCols AS (
    SELECT 
        ic.object_id,
        ic.column_id
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic
        ON i.object_id = ic.object_id
       AND i.index_id  = ic.index_id
    WHERE i.is_primary_key = 1
),
DefaultConstraints AS (
    SELECT 
        dc.parent_object_id  AS object_id,
        dc.parent_column_id  AS column_id,
        dc.definition        AS DefaultDefinition
    FROM sys.default_constraints dc
)
SELECT
    s.name           AS SchemaName,
    t.name           AS TableName,
    rc.TotalRows     AS _RowCount,
    c.column_id      AS OrdinalPosition,
    c.name           AS ColumnName,
    ty.name          AS ColumnDataType,
    c.max_length     AS MaxLength,
    c.precision      AS [Precision],
    c.scale          AS [Scale],
    c.is_nullable    AS IsNullable,
    c.is_identity    AS IsIdentity,
    c.is_computed    AS IsComputed,
    dc.DefaultDefinition,
    CASE WHEN pk.object_id IS NOT NULL THEN 1 ELSE 0 END AS IsPrimaryKey
FROM sys.tables t
INNER JOIN sys.schemas s
    ON t.schema_id = s.schema_id
INNER JOIN sys.columns c
    ON t.object_id = c.object_id
INNER JOIN sys.types ty
    ON c.user_type_id = ty.user_type_id
LEFT JOIN RowCounts rc
    ON t.object_id = rc.object_id
LEFT JOIN PrimaryKeyCols pk
    ON c.object_id = pk.object_id
   AND c.column_id = pk.column_id
LEFT JOIN DefaultConstraints dc
    ON c.object_id = dc.object_id
   AND c.column_id = dc.column_id
WHERE 
    t.is_ms_shipped = 0
    AND (rc.TotalRows IS NULL OR rc.TotalRows <> 0)  -- exclude empty tables if desired
ORDER BY 
    s.name,
    t.name,
    c.column_id;
GO

/*===============================================================================
  2) List of all primary keys in all user tables + general info
===============================================================================*/

SELECT 
    s.name          AS SchemaName,
    so.name         AS TableName,
    c.name          AS ColumnName,
    t.name          AS DataType,
    c.max_length    AS MaxLength,
    c.precision     AS [Precision],
    c.scale         AS [Scale],
    1               AS IsPrimaryKey
FROM sys.columns c
INNER JOIN sys.types t 
    ON c.user_type_id = t.user_type_id
INNER JOIN sys.objects so 
    ON c.object_id = so.object_id
INNER JOIN sys.schemas s
    ON so.schema_id = s.schema_id
INNER JOIN sys.index_columns ic 
    ON ic.object_id = c.object_id 
   AND ic.column_id = c.column_id
INNER JOIN sys.indexes i 
    ON ic.object_id = i.object_id 
   AND ic.index_id  = i.index_id
WHERE 
    i.is_primary_key = 1
    AND so.type = 'U'   -- user tables
ORDER BY 
    s.name,
    so.name,
    c.column_id;
GO


/*===============================================================================
  3) Optional: Foreign key relationships (uncomment if useful)
===============================================================================*/

/*

SELECT 
    fk.name               AS ForeignKeyName,
    sch.name              AS SchemaName,
    t.name                AS TableName,
    c.name                AS ColumnName,
    sch_ref.name          AS RefSchemaName,
    t_ref.name            AS RefTableName,
    c_ref.name            AS RefColumnName
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.tables t
    ON fkc.parent_object_id = t.object_id
INNER JOIN sys.schemas sch
    ON t.schema_id = sch.schema_id
INNER JOIN sys.columns c
    ON fkc.parent_object_id = c.object_id
   AND fkc.parent_column_id = c.column_id
INNER JOIN sys.tables t_ref
    ON fkc.referenced_object_id = t_ref.object_id
INNER JOIN sys.schemas sch_ref
    ON t_ref.schema_id = sch_ref.schema_id
INNER JOIN sys.columns c_ref
    ON fkc.referenced_object_id = c_ref.object_id
   AND fkc.referenced_column_id = c_ref.column_id
ORDER BY 
    sch.name,
    t.name,
    fk.name,
    fkc.constraint_column_id;
GO

*/

