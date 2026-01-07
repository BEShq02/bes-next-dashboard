-- ============================================
-- 所有人員對認證模板的查看權限查詢（樹狀結構版本）
-- ============================================
-- 說明：查詢所有人員對認證模板的查看權限
-- 表格欄位：工號、姓名、權限快速配置、範本名稱、查看權限
-- 
-- 根據 finedb-schema.md 的說明：
-- 1. 認證模板和人員權限的設定是有階層的（資料夾樹狀結構）
-- 2. 認證模板可以是某個資料夾也可以是 .frm 檔案
-- 3. 人員權限的設定也是一樣的（樹狀結構）
-- 4. 權限繼承：如果父目錄有權限，子模板會繼承該權限（支持多層級）
-- 
-- 權限邏輯說明：
-- 1. authorityType = 1：目錄權限
-- 2. authorityType = 3：模板權限
-- 3. authorityType = 101：認證模板權限（需要認證的範本）
-- 4. authorityType = 102：普通權限配置（權限快速配置）
-- 5. authorityType = 103：填報權限
-- 6. authorityEntityType = 0：目錄
-- 7. authorityEntityType = 101：模板（.frm檔案）
-- 8. authority = 1：查看權限
-- 9. authority = 2：導出權限（包含查看）
-- 10. authority = 3：管理權限（包含查看和導出）
-- ============================================
-- ============================================
-- 步驟 1：獲取所有認證模板（樹狀結構）
-- ============================================
-- 認證模板定義：authorityType = 101 且 authorityEntityType = 101 的 .frm 檔案
-- ============================================
WITH certified_templates AS (
    -- 獲取所有需認證的模板及其完整路徑（樹狀結構）
    SELECT DISTINCT a.id AS authority_id,
        a.roleId,
        a.roleType,
        a.authorityEntityId AS 原始路徑,
        COALESCE(ao.fullPath, ao.path, a.authorityEntityId) AS 完整路徑,
        a.authority AS 權限值,
        a.authorityType,
        a.authorityEntityType
    FROM fine_authority a
        LEFT JOIN fine_authority_object ao ON a.id = ao.expandId
    WHERE a.authorityType = 101
        AND a.authorityEntityType = 101
        AND a.authorityEntityId LIKE '%.frm'
        AND a.authority >= 1 -- 至少要有查看權限
),
-- ============================================
-- 步驟 2：獲取所有使用者及其角色資訊
-- ============================================
all_users AS (
    SELECT u.id AS userId,
        u.userName AS 工號,
        u.realName AS 姓名,
        u.enable AS 是否啟用
    FROM fine_user u
    WHERE u.userName IS NOT NULL
        AND u.enable = 1
),
-- ============================================
-- 步驟 3：獲取使用者的角色（包括部門職位角色和自訂角色）
-- ============================================
user_roles AS (
    SELECT au.userId,
        au.工號,
        au.姓名,
        urm.roleId,
        urm.roleType,
        -- 角色類型說明：1=部門職位角色，2=自訂角色
        CASE
            WHEN urm.roleType = 1 THEN '部門職位角色'
            WHEN urm.roleType = 2 THEN '自訂角色'
            ELSE '未知'
        END AS 角色類型說明,
        -- 檢查是否為特殊角色
        CASE
            WHEN cr.name = 'SUPERVIEWER' THEN 1
            ELSE 0
        END AS is_superviewer,
        CASE
            WHEN cr.name = 'VIEWER' THEN 1
            ELSE 0
        END AS is_viewer,
        CASE
            WHEN urm.roleId = 'super-user-custom-role' THEN 1
            ELSE 0
        END AS is_superuser
    FROM all_users au
        LEFT JOIN fine_user_role_middle urm ON au.userId = urm.userId
        LEFT JOIN fine_custom_role cr ON urm.roleId = cr.id
        AND urm.roleType = 2
),
-- ============================================
-- 步驟 4：獲取所有目錄權限（用於權限繼承檢查）
-- ============================================
-- 目錄權限定義：
-- 1. authorityEntityType = 0：目錄
-- 2. authorityType IN (1, 3, 101, 102, 103)：各種權限類型
-- 3. authority >= 1：至少要有查看權限
-- 4. 不是 .frm 或 .cpt 檔案（排除檔案，只保留目錄）
-- ============================================
directory_permissions AS (
    SELECT DISTINCT a.roleId,
        a.roleType,
        a.authorityEntityId AS 原始目錄路徑,
        COALESCE(ao.fullPath, ao.path, a.authorityEntityId) AS 目錄完整路徑,
        a.authority AS 權限值,
        a.authorityType,
        a.authorityEntityType
    FROM fine_authority a
        LEFT JOIN fine_authority_object ao ON a.id = ao.expandId
    WHERE a.authorityEntityType = 0 -- 目錄類型
        AND a.authorityType IN (1, 3, 101, 102, 103) -- 各種權限類型
        AND a.authority >= 1 -- 至少要有查看權限
        AND a.authorityEntityId NOT LIKE '%.frm' -- 排除 .frm 檔案
        AND a.authorityEntityId NOT LIKE '%.cpt' -- 排除 .cpt 檔案
),
-- ============================================
-- 步驟 5：獲取所有模板權限（直接權限，非認證模板）
-- ============================================
-- 模板權限定義：
-- 1. authorityEntityType = 101：模板
-- 2. authorityType IN (3, 101, 102, 103)：模板相關權限類型
-- 3. authority >= 1：至少要有查看權限
-- ============================================
template_permissions AS (
    SELECT DISTINCT a.roleId,
        a.roleType,
        a.authorityEntityId AS 原始模板路徑,
        COALESCE(ao.fullPath, ao.path, a.authorityEntityId) AS 模板完整路徑,
        a.authority AS 權限值,
        a.authorityType,
        a.authorityEntityType
    FROM fine_authority a
        LEFT JOIN fine_authority_object ao ON a.id = ao.expandId
    WHERE a.authorityEntityType = 101 -- 模板類型
        AND a.authorityType IN (3, 101, 102, 103) -- 模板相關權限類型
        AND a.authority >= 1 -- 至少要有查看權限
),
-- ============================================
-- 步驟 6：計算使用者對認證模板的查看權限
-- ============================================
-- 權限判斷邏輯（按優先順序）：
-- 1. superuser 角色：直接返回 TRUE（擁有所有權限）
-- 2. VIEWER/SUPERVIEWER 角色：直接返回 TRUE（權限快速配置）
-- 3. 直接模板權限：檢查使用者角色是否有該認證模板的直接權限
-- 4. 目錄權限繼承：檢查認證模板是否在擁有權限的目錄下（樹狀結構繼承）
-- ============================================
user_template_permissions AS (
    SELECT au.工號,
        au.姓名,
        -- 權限快速配置
        CASE
            WHEN MAX(ur.is_superviewer) = 1 THEN 'SUPERVIEWER'
            WHEN MAX(ur.is_viewer) = 1 THEN 'VIEWER'
            WHEN MAX(ur.is_superuser) = 1 THEN 'SUPERUSERS'
            ELSE '無'
        END AS 權限快速配置,
        ct.完整路徑 AS 範本名稱,
        ct.原始路徑 AS 範本原始路徑,
        -- 查看權限判斷
        CASE
            -- 1. superuser 角色：直接擁有所有權限
            WHEN MAX(ur.is_superuser) = 1 THEN 'TRUE' -- 2. VIEWER/SUPERVIEWER 角色：權限快速配置，擁有所有模板的查看權限
            WHEN MAX(ur.is_viewer) = 1
            OR MAX(ur.is_superviewer) = 1 THEN 'TRUE' -- 3. 直接模板權限：檢查使用者角色是否有該認證模板的直接權限
            WHEN EXISTS (
                SELECT 1
                FROM user_roles ur2
                    INNER JOIN template_permissions tp ON ur2.roleId = tp.roleId
                    AND ur2.roleType = tp.roleType
                WHERE ur2.userId = au.userId
                    AND (
                        -- 完整路徑匹配
                        tp.模板完整路徑 = ct.完整路徑 -- 原始路徑匹配
                        OR tp.原始模板路徑 = ct.原始路徑
                    )
            ) THEN 'TRUE' -- 4. 目錄權限繼承：檢查認證模板是否在擁有權限的目錄下（樹狀結構繼承）
            WHEN EXISTS (
                SELECT 1
                FROM user_roles ur2
                    INNER JOIN directory_permissions dp ON ur2.roleId = dp.roleId
                    AND ur2.roleType = dp.roleType
                WHERE ur2.userId = au.userId
                    AND dp.目錄完整路徑 IS NOT NULL
                    AND dp.原始目錄路徑 IS NOT NULL
                    AND ct.完整路徑 IS NOT NULL
                    AND ct.原始路徑 IS NOT NULL
                    AND (
                        -- 模板完整路徑以目錄完整路徑開頭（支持多層級繼承）
                        ct.完整路徑 LIKE (dp.目錄完整路徑 + '/%')
                        OR ct.完整路徑 = dp.目錄完整路徑 -- 原始路徑匹配（兼容性）
                        OR ct.原始路徑 LIKE (dp.原始目錄路徑 + '/%')
                        OR ct.原始路徑 = dp.原始目錄路徑
                    )
            ) THEN 'TRUE'
            ELSE 'FALSE'
        END AS 查看權限
    FROM all_users au
        CROSS JOIN certified_templates ct
        LEFT JOIN user_roles ur ON au.userId = ur.userId
    GROUP BY au.userId,
        au.工號,
        au.姓名,
        ct.完整路徑,
        ct.原始路徑
) -- ============================================
-- 主要查詢：生成完整的使用者-模板權限表格
-- ============================================
SELECT 工號,
    姓名,
    權限快速配置,
    範本名稱,
    查看權限
FROM user_template_permissions
ORDER BY 工號,
    範本名稱;
-- ============================================
-- 驗證查詢：檢查特定使用者的權限（用於驗證）
-- ============================================
-- 使用方式：將 '226178' 替換為要查詢的工號
-- ============================================
/*
 WITH certified_templates AS (
 SELECT DISTINCT
 a.id AS authority_id,
 a.authorityEntityId AS 原始路徑,
 COALESCE(ao.fullPath, ao.path, a.authorityEntityId) AS 完整路徑
 FROM fine_authority a
 LEFT JOIN fine_authority_object ao ON a.id = ao.expandId
 WHERE a.authorityType = 101
 AND a.authorityEntityType = 101
 AND a.authorityEntityId LIKE '%.frm'
 AND a.authority >= 1
 ),
 user_roles AS (
 SELECT 
 u.id AS userId,
 u.userName AS 工號,
 u.realName AS 姓名,
 urm.roleId,
 urm.roleType,
 CASE WHEN cr.name = 'SUPERVIEWER' THEN 1 ELSE 0 END AS is_superviewer,
 CASE WHEN cr.name = 'VIEWER' THEN 1 ELSE 0 END AS is_viewer,
 CASE WHEN urm.roleId = 'super-user-custom-role' THEN 1 ELSE 0 END AS is_superuser
 FROM fine_user u
 LEFT JOIN fine_user_role_middle urm ON u.id = urm.userId
 LEFT JOIN fine_custom_role cr ON urm.roleId = cr.id AND urm.roleType = 2
 WHERE u.userName = '226178'  -- 替換為要查詢的工號
 AND u.enable = 1
 ),
 directory_permissions AS (
 SELECT DISTINCT
 a.roleId,
 a.roleType,
 a.authorityEntityId AS 原始目錄路徑,
 COALESCE(ao.fullPath, ao.path, a.authorityEntityId) AS 目錄完整路徑
 FROM fine_authority a
 LEFT JOIN fine_authority_object ao ON a.id = ao.expandId
 WHERE a.authorityEntityType = 0
 AND a.authorityType IN (1, 3, 101, 102, 103)
 AND a.authority >= 1
 AND a.authorityEntityId NOT LIKE '%.frm'
 AND a.authorityEntityId NOT LIKE '%.cpt'
 ),
 template_permissions AS (
 SELECT DISTINCT
 a.roleId,
 a.roleType,
 a.authorityEntityId AS 原始模板路徑,
 COALESCE(ao.fullPath, ao.path, a.authorityEntityId) AS 模板完整路徑
 FROM fine_authority a
 LEFT JOIN fine_authority_object ao ON a.id = ao.expandId
 WHERE a.authorityEntityType = 101
 AND a.authorityType IN (3, 101, 102, 103)
 AND a.authority >= 1
 )
 SELECT 
 ur.工號,
 ur.姓名,
 CASE
 WHEN MAX(ur.is_superviewer) = 1 THEN 'SUPERVIEWER'
 WHEN MAX(ur.is_viewer) = 1 THEN 'VIEWER'
 WHEN MAX(ur.is_superuser) = 1 THEN 'SUPERUSERS'
 ELSE '無'
 END AS 權限快速配置,
 ct.完整路徑 AS 範本名稱,
 CASE
 WHEN MAX(ur.is_superuser) = 1 THEN 'TRUE'
 WHEN MAX(ur.is_viewer) = 1 OR MAX(ur.is_superviewer) = 1 THEN 'TRUE'
 WHEN EXISTS (
 SELECT 1
 FROM user_roles ur2
 INNER JOIN template_permissions tp 
 ON ur2.roleId = tp.roleId 
 AND ur2.roleType = tp.roleType
 WHERE ur2.userId = ur.userId
 AND (
 tp.模板完整路徑 = ct.完整路徑
 OR tp.原始模板路徑 = ct.原始路徑
 )
 ) THEN 'TRUE'
 WHEN EXISTS (
 SELECT 1
 FROM user_roles ur2
 INNER JOIN directory_permissions dp 
 ON ur2.roleId = dp.roleId 
 AND ur2.roleType = dp.roleType
 WHERE ur2.userId = ur.userId
 AND dp.目錄完整路徑 IS NOT NULL
 AND dp.原始目錄路徑 IS NOT NULL
 AND ct.完整路徑 IS NOT NULL
 AND ct.原始路徑 IS NOT NULL
 AND (
 ct.完整路徑 LIKE (dp.目錄完整路徑 + '/%')
 OR ct.完整路徑 = dp.目錄完整路徑
 OR ct.原始路徑 LIKE (dp.原始目錄路徑 + '/%')
 OR ct.原始路徑 = dp.原始目錄路徑
 )
 ) THEN 'TRUE'
 ELSE 'FALSE'
 END AS 查看權限
 FROM user_roles ur
 CROSS JOIN certified_templates ct
 GROUP BY 
 ur.userId,
 ur.工號,
 ur.姓名,
 ct.完整路徑,
 ct.原始路徑
 ORDER BY ct.完整路徑;
 */
-- ============================================
-- 統計查詢：查看權限統計
-- ============================================
/*
 SELECT 
 COUNT(DISTINCT utp.工號) AS 總使用者數,
 COUNT(DISTINCT CASE WHEN utp.權限快速配置 IN ('VIEWER', 'SUPERVIEWER', 'SUPERUSERS') THEN utp.工號 END) AS 有權限快速配置的使用者數,
 COUNT(DISTINCT utp.範本名稱) AS 認證模板數,
 COUNT(CASE WHEN utp.查看權限 = 'TRUE' THEN 1 END) AS 有查看權限的記錄數,
 COUNT(CASE WHEN utp.查看權限 = 'FALSE' THEN 1 END) AS 無查看權限的記錄數
 FROM user_template_permissions utp;
 */
-- ============================================
-- 說明文件
-- ============================================
-- 
-- 權限邏輯說明：
-- 1. 認證模板定義：authorityType = 101 且 authorityEntityType = 101 的 .frm 檔案
-- 2. 目錄權限定義：authorityEntityType = 0 且不是檔案的權限記錄
-- 3. 模板權限定義：authorityEntityType = 101 的權限記錄
-- 4. 權限繼承：如果父目錄有權限，子模板會繼承該權限（支持多層級繼承）
-- 5. 查看權限判斷順序：
--    a. superuser 角色：直接返回 TRUE（擁有所有權限）
--    b. VIEWER/SUPERVIEWER 角色：直接返回 TRUE（權限快速配置）
--    c. 直接模板權限：檢查使用者角色是否有該認證模板的直接權限
--    d. 目錄權限繼承：檢查認證模板是否在擁有權限的目錄下（樹狀結構繼承）
--
-- 路徑處理說明：
-- - 使用 fine_authority_object 表的 fullPath 或 path 欄位獲取完整路徑
-- - 如果 fine_authority_object 沒有記錄，則使用 fine_authority.authorityEntityId 作為路徑
-- - 支持多層級目錄繼承，例如：
--   * 公共工程事業部/工務所管控模組/工令工程月進度及淨利.frm
--   * 成控處/投備標模組/成本管理模組.frm
--
-- 權限值說明：
-- - authority = 1：查看權限
-- - authority = 2：導出權限（包含查看）
-- - authority = 3：管理權限（包含查看和導出）
--
-- 查詢結果說明：
-- - 查詢會顯示所有啟用的使用者對所有認證模板的查看權限
-- - 權限可能來自：
--   1. superuser 角色（直接擁有所有權限）
--   2. VIEWER/SUPERVIEWER 角色（權限快速配置）
--   3. 直接模板權限（authorityType = 3, 101, 102, 103）
--   4. 目錄權限繼承（多層級目錄結構）
--
-- 修正重點：
-- 1. 根據 finedb-schema.md 的說明，正確區分目錄權限（authorityEntityType = 0）和模板權限（authorityEntityType = 101）
-- 2. 支持樹狀結構的權限繼承（目錄權限可以繼承給子目錄和子模板）
-- 3. 查詢所有使用者，不只是有特殊角色的使用者
-- 4. 使用 fine_authority_object 獲取完整路徑，確保路徑準確性
-- 5. 同時檢查完整路徑和原始路徑，確保兼容性
-- ============================================