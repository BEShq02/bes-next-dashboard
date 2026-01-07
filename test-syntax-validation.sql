-- ============================================
-- SQL 語法驗證查詢
-- ============================================
-- 此查詢用於驗證主要查詢的語法是否正確
-- 如果此查詢可以執行，則主要查詢應該也可以執行
-- ============================================

-- 測試 1：驗證 CTE 基本語法
WITH test_cte AS (
    SELECT 1 AS test_value
)
SELECT test_value FROM test_cte;

-- 測試 2：驗證字符串連接語法（SQL Server）
SELECT 'test' + '/' + '%' AS test_concatenation;

-- 測試 3：驗證 LIKE 語法
SELECT CASE 
    WHEN 'test/path.frm' LIKE 'test/%' THEN 'TRUE'
    ELSE 'FALSE'
END AS test_like;

-- 測試 4：驗證 COALESCE 語法
SELECT COALESCE(NULL, NULL, 'default') AS test_coalesce;

-- 測試 5：驗證 EXISTS 子查詢語法
SELECT CASE
    WHEN EXISTS (SELECT 1 WHERE 1=1) THEN 'TRUE'
    ELSE 'FALSE'
END AS test_exists;

-- ============================================
-- 如果以上查詢都能執行，則主要查詢應該也可以執行
-- ============================================

