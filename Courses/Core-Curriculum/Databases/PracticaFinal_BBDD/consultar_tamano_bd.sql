SELECT 
    table_schema AS "Base de Datos", 
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Tamaño (MB)" 
FROM information_schema.tables 
WHERE table_schema = 'streaming'
GROUP BY table_schema;