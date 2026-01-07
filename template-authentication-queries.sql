-- ============================================
-- FineReport 模板認證查詢 SQL
-- ============================================
-- 說明：查詢 FineDB 資料庫中所有需要認證的模板（畫面）
-- 認證條件：authorityType = 101 且 authorityEntityType = 101 且 authorityEntityId LIKE '%.frm'
-- ============================================
-- ============================================
-- 1. 基礎查詢：列出所有需要認證的模板
-- ============================================
SELECT DISTINCT authorityEntityId AS 模板路徑
FROM fine_authority
WHERE authorityType = 101
  AND authorityEntityType = 101
  AND authorityEntityId LIKE '%.frm'
ORDER BY authorityEntityId;
-- ============================================
-- 2. 詳細查詢：包含權限值和角色資訊
-- ============================================
SELECT a.authorityEntityId AS 模板路徑,
  a.authority AS 權限值,
  CASE
    WHEN a.authority = 1 THEN '查看'
    WHEN a.authority = 2 THEN '導出'
    WHEN a.authority = 3 THEN '管理'
    ELSE '未知'
  END AS 權限說明,
  a.roleId AS 角色ID,
  CASE
    WHEN a.roleType = 1 THEN '部門職位角色'
    WHEN a.roleType = 2 THEN '自訂角色'
    WHEN a.roleType = 3 THEN '使用者角色'
    ELSE '未知'
  END AS 角色類型,
  COALESCE(cr.name, 'N/A') AS 角色名稱
FROM fine_authority a
  LEFT JOIN fine_custom_role cr ON a.roleId = cr.id
  AND a.roleType = 2
WHERE a.authorityType = 101
  AND a.authorityEntityType = 101
  AND a.authorityEntityId LIKE '%.frm'
ORDER BY a.authorityEntityId,
  a.authority;
-- ============================================
-- 3. 統計查詢：認證模板統計資訊
-- ============================================
SELECT COUNT(DISTINCT authorityEntityId) AS 需要認證的模板總數,
  COUNT(*) AS 認證記錄總數,
  COUNT(DISTINCT roleId) AS 涉及的角色數,
  SUM(
    CASE
      WHEN authority = 1 THEN 1
      ELSE 0
    END
  ) AS 查看權限數,
  SUM(
    CASE
      WHEN authority = 2 THEN 1
      ELSE 0
    END
  ) AS 導出權限數,
  SUM(
    CASE
      WHEN authority = 3 THEN 1
      ELSE 0
    END
  ) AS 管理權限數
FROM fine_authority
WHERE authorityType = 101
  AND authorityEntityType = 101
  AND authorityEntityId LIKE '%.frm';
-- ============================================
-- 4. 按部門分類查詢
-- ============================================
SELECT CASE
    WHEN authorityEntityId LIKE '成控處/%' THEN '成控處'
    WHEN authorityEntityId LIKE '人總處/%' THEN '人總處'
    WHEN authorityEntityId LIKE '工程工務處/%' THEN '工程工務處'
    WHEN authorityEntityId LIKE '公共工程事業部/%' THEN '公共工程事業部'
    WHEN authorityEntityId LIKE '房地產事業部/%' THEN '房地產事業部'
    WHEN authorityEntityId LIKE '00.FR測試/%' THEN 'FR測試'
    ELSE '其他'
  END AS 部門,
  COUNT(DISTINCT authorityEntityId) AS 模板數量,
  STRING_AGG(DISTINCT authorityEntityId, ', ') AS 模板列表
FROM fine_authority
WHERE authorityType = 101
  AND authorityEntityType = 101
  AND authorityEntityId LIKE '%.frm'
GROUP BY CASE
    WHEN authorityEntityId LIKE '成控處/%' THEN '成控處'
    WHEN authorityEntityId LIKE '人總處/%' THEN '人總處'
    WHEN authorityEntityId LIKE '工程工務處/%' THEN '工程工務處'
    WHEN authorityEntityId LIKE '公共工程事業部/%' THEN '公共工程事業部'
    WHEN authorityEntityId LIKE '房地產事業部/%' THEN '房地產事業部'
    WHEN authorityEntityId LIKE '00.FR測試/%' THEN 'FR測試'
    ELSE '其他'
  END
ORDER BY 模板數量 DESC;
-- ============================================
-- 5. 查詢特定模板的認證資訊（範例：成本管理模組）
-- ============================================
SELECT a.authorityEntityId AS 模板路徑,
  a.authority AS 權限值,
  CASE
    WHEN a.authority = 1 THEN '查看'
    WHEN a.authority = 2 THEN '導出'
    WHEN a.authority = 3 THEN '管理'
    ELSE '未知'
  END AS 權限說明,
  a.roleId AS 角色ID,
  COALESCE(cr.name, 'N/A') AS 角色名稱,
  a.roleType AS 角色類型代碼
FROM fine_authority a
  LEFT JOIN fine_custom_role cr ON a.roleId = cr.id
  AND a.roleType = 2
WHERE a.authorityType = 101
  AND a.authorityEntityType = 101
  AND a.authorityEntityId LIKE '%成本管理模組%'
ORDER BY a.authorityEntityId;
-- ============================================
-- 6. 查詢成控處所有需要認證的模板
-- ============================================
SELECT DISTINCT authorityEntityId AS 模板路徑,
  authority AS 權限值,
  CASE
    WHEN authority = 1 THEN '查看'
    WHEN authority = 2 THEN '導出'
    WHEN authority = 3 THEN '管理'
    ELSE '未知'
  END AS 權限說明
FROM fine_authority
WHERE authorityType = 101
  AND authorityEntityType = 101
  AND authorityEntityId LIKE '成控處/%'
  AND authorityEntityId LIKE '%.frm'
ORDER BY authorityEntityId;
-- ============================================
-- 7. 完整查詢：包含使用者資訊（如果有使用者角色）
-- ============================================
SELECT a.authorityEntityId AS 模板路徑,
  a.authority AS 權限值,
  CASE
    WHEN a.authority = 1 THEN '查看'
    WHEN a.authority = 2 THEN '導出'
    WHEN a.authority = 3 THEN '管理'
    ELSE '未知'
  END AS 權限說明,
  a.roleId AS 角色ID,
  CASE
    WHEN a.roleType = 1 THEN '部門職位角色'
    WHEN a.roleType = 2 THEN '自訂角色'
    WHEN a.roleType = 3 THEN '使用者角色'
    ELSE '未知'
  END AS 角色類型,
  COALESCE(cr.name, u.realName, 'N/A') AS 角色或使用者名稱
FROM fine_authority a
  LEFT JOIN fine_custom_role cr ON a.roleId = cr.id
  AND a.roleType = 2
  LEFT JOIN fine_user u ON a.roleId = u.id
  AND a.roleType = 3
WHERE a.authorityType = 101
  AND a.authorityEntityType = 101
  AND a.authorityEntityId LIKE '%.frm'
ORDER BY a.authorityEntityId,
  a.authority;
-- ============================================
-- 查詢結果說明
-- ============================================
-- 目前共有 16 個模板需要認證：
-- 1. 00.FR測試/（副本）部門人力資源的副本.frm
-- 2. 人總處/部門人力資源.frm
-- 3. 人總處/部門人力資源_離職.frm
-- 4. 工程工務處/工令工程月進度及淨利.frm
-- 5. 工程工務處/進度管控.frm
-- 6. 公共工程事業部/工程工務處管控模組/計價管控-計價達成比較.frm
-- 7. 成控處/CCI計算機.frm
-- 8. 成控處/人月產值分析.frm
-- 9. 成控處/人月產值報表.frm
-- 10. 成控處/成本管理模組.frm
-- 11. 成控處/成本管理模組報表.frm
-- 12. 成控處/營造工程物價指數.frm
-- 13. 成控處/營造工程物價指數報表.frm
-- 14. 成控處/營造物價指數首頁_01版.frm
-- 15. 房地產事業部/房地產事業部管控模組.frm
-- 16. 導覽頁面.frm
--
-- 所有認證模板都關聯到 'super-user-custom-role' 角色（superusers）
-- 權限值說明：
--   - 1 = 查看權限
--   - 2 = 導出權限
--   - 3 = 管理權限
-- ============================================