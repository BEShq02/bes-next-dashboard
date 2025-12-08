'use client'

import { formatNumber2 } from '@/utils/fm'

import { Box, Card, Chip, Typography, CardContent } from '@mui/material'
import {
  Security as SecurityIcon,
  Functions as FunctionsIcon,
  Description as DescriptionIcon,
  AttachMoney as AttachMoneyIcon,
  AccountBalance as AccountBalanceIcon,
} from '@mui/icons-material'

// 保固金種類配置 - 與 EnsureTypeChip.jsx 一致
const ENSURE_TYPE_CONFIG = {
  切結書: {
    icon: <DescriptionIcon />,
    color: '#1976d2', // 藍色
    backgroundColor: '#e3f2fd',
  },
  定存單: {
    icon: <AccountBalanceIcon />,
    color: '#388e3c', // 綠色
    backgroundColor: '#e8f5e8',
  },
  保證書: {
    icon: <SecurityIcon />,
    color: '#f57c00', // 橙色
    backgroundColor: '#fff3e0',
  },
  現金: {
    icon: <AttachMoneyIcon />,
    color: '#d32f2f', // 紅色
    backgroundColor: '#ffebee',
  },
}

// 預設顏色配置（用於整體保固狀況）
const DEFAULT_COLOR = {
  primary: '#1976d2',
  secondary: '#e3f2fd',
}

/**
 * 簡化的指標卡片組件
 * @param {Object} props
 * @param {string} props.title - 卡片標題
 * @param {Object} props.countData - 筆數資料 {expired, total}
 * @param {Object} props.amountData - 金額資料 {expired, total}
 * @param {string} props.ensureType - 保固金種類 (可選，用於顏色和chip)
 * @param {boolean} props.showIcon - 是否顯示圖標 (整體保固狀況顯示)
 * @param {Function} props.onClick - 點擊處理函數
 * @param {boolean} props.isSelected - 是否被選中
 * @param {Object} props.sx - 額外樣式
 */
export default function MetricCard({
  title,
  countData = { expired: 0, total: 0 },
  amountData = { expired: 0, total: 0 },
  ensureType,
  showIcon = false,
  onClick,
  isSelected = false,
  sx = {},
}) {
  // 獲取顏色配置
  const getColors = () => {
    if (ensureType && ENSURE_TYPE_CONFIG[ensureType]) {
      return ENSURE_TYPE_CONFIG[ensureType]
    }
    return DEFAULT_COLOR
  }

  const colors = getColors()

  // 格式化筆數顯示
  const formatCount = value => {
    return value.toLocaleString('zh-TW')
  }

  // 格式化金額顯示
  const formatAmount = value => {
    return formatNumber2(value)
  }

  // if (!mounted) {
  //   return (
  //     <Card
  //       elevation={2}
  //       suppressHydrationWarning
  //       sx={{
  //         borderRadius: '12px',
  //         background: colors.backgroundColor || colors.secondary,
  //         border: `1px solid ${colors.color || colors.primary}20`,
  //         transition: 'all 0.2s ease-in-out',
  //         position: 'relative',
  //         ...sx,
  //       }}
  //     >
  //       <CardContent sx={{ p: 2, pb: 2 }}>
  //         {/* 頂部區域 */}
  //         <Box
  //           sx={{
  //             display: 'flex',
  //             justifyContent: showIcon ? 'flex-start' : 'space-between',
  //             alignItems: showIcon ? 'center' : 'flex-start',
  //             mb: 1,
  //             gap: showIcon ? 1 : 0,
  //           }}
  //         >
  //           {/* 保固種類 Chip (左上角) - 只有保固金種類顯示 */}
  //           {ensureType && (
  //             <Chip
  //               icon={colors.icon}
  //               label={ensureType}
  //               variant="outlined"
  //               size="small"
  //               sx={{
  //                 borderColor: colors.color,
  //                 color: colors.color,
  //                 backgroundColor: 'rgba(255,255,255,0.8)',
  //                 fontSize: '11px',
  //                 height: '20px',
  //                 '& .MuiChip-icon': {
  //                   color: colors.color,
  //                   fontSize: '14px !important',
  //                 },
  //                 '& .MuiChip-label': {
  //                   px: 0.5,
  //                   fontWeight: 600,
  //                 },
  //               }}
  //             />
  //           )}

  //           {/* 圖標和標題 - 整體保固狀況水平排列 */}
  //           {showIcon && (
  //             <>
  //               <Box
  //                 sx={{
  //                   width: 32,
  //                   height: 32,
  //                   borderRadius: '8px',
  //                   backgroundColor: colors.color || colors.primary,
  //                   display: 'flex',
  //                   alignItems: 'center',
  //                   justifyContent: 'center',
  //                   color: 'white',
  //                   flexShrink: 0,
  //                   '& svg': { fontSize: '18px' },
  //                 }}
  //               >
  //                 <FunctionsIcon />
  //               </Box>
  //               <Typography
  //                 variant="body2"
  //                 sx={{
  //                   fontWeight: 600,
  //                   color: colors.color || colors.primary,
  //                   fontSize: '13px',
  //                   lineHeight: 1.2,
  //                 }}
  //               >
  //                 {title}
  //               </Typography>
  //             </>
  //           )}
  //         </Box>

  //         {/* 標題 - 只有保固金種類顯示 */}
  //         {!showIcon && title && (
  //           <Typography
  //             variant="body2"
  //             sx={{
  //               fontWeight: 600,
  //               color: colors.color || colors.primary,
  //               fontSize: '13px',
  //             }}
  //           >
  //             {title}
  //           </Typography>
  //         )}

  //         {/* 主要數值顯示 - 兩行資料 */}
  //         <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5 }}>
  //           {/* 第一行：筆數資料 */}
  //           <Box
  //             sx={{
  //               display: 'flex',
  //               alignItems: 'baseline',
  //               gap: 0.5,
  //               flexDirection: 'column',
  //             }}
  //           >
  //             <Typography
  //               variant="body2"
  //               sx={{
  //                 color: colors.color || colors.primary,
  //                 opacity: 0.8,
  //                 fontWeight: 600,
  //                 fontSize: '11px',
  //                 minWidth: 'fit-content',
  //               }}
  //             >
  //               未解除保固筆數
  //             </Typography>
  //             <Box
  //               sx={{
  //                 display: 'flex',
  //                 alignItems: 'baseline',
  //                 width: '100%',
  //                 justifyContent: 'center',
  //               }}
  //             >
  //               <Typography
  //                 variant="h6"
  //                 sx={{
  //                   fontWeight: 700,
  //                   color: colors.color || colors.primary,
  //                   lineHeight: 1.2,
  //                   fontSize: '16px',
  //                 }}
  //               >
  //                 {formatCount(countData.expired)}
  //               </Typography>
  //               <Typography
  //                 variant="body2"
  //                 sx={{
  //                   color: colors.color || colors.primary,
  //                   opacity: 0.7,
  //                   fontWeight: 600,
  //                   fontSize: '12px',
  //                   ml: 0.5,
  //                 }}
  //               >
  //                 / {formatCount(countData.total)}
  //               </Typography>
  //             </Box>
  //           </Box>

  //           {/* 第二行：金額資料 */}
  //           <Box
  //             sx={{
  //               display: 'flex',
  //               alignItems: 'baseline',
  //               gap: 0.5,
  //               flexDirection: 'column',
  //             }}
  //           >
  //             <Typography
  //               variant="body2"
  //               sx={{
  //                 color: colors.color || colors.primary,
  //                 opacity: 0.8,
  //                 fontWeight: 600,
  //                 fontSize: '11px',
  //                 minWidth: 'fit-content',
  //               }}
  //             >
  //               未解除保固金額
  //             </Typography>
  //             <Box
  //               sx={{
  //                 display: 'flex',
  //                 alignItems: 'baseline',
  //                 width: '100%',
  //                 justifyContent: 'center',
  //               }}
  //             >
  //               <Typography
  //                 variant="h6"
  //                 sx={{
  //                   fontWeight: 700,
  //                   color: colors.color || colors.primary,
  //                   lineHeight: 1.2,
  //                   fontSize: '16px',
  //                 }}
  //               >
  //                 {formatAmount(amountData.expired)}
  //               </Typography>
  //               <Typography
  //                 variant="body2"
  //                 sx={{
  //                   color: colors.color || colors.primary,
  //                   opacity: 0.7,
  //                   fontWeight: 600,
  //                   fontSize: '12px',
  //                   ml: 0.5,
  //                 }}
  //               >
  //                 / {formatAmount(amountData.total)}
  //               </Typography>
  //             </Box>
  //           </Box>
  //         </Box>
  //       </CardContent>
  //     </Card>
  //   )
  // }

  return (
    <Card
      elevation={isSelected ? 4 : 2}
      onClick={onClick}
      sx={{
        borderRadius: '12px',
        background: colors.backgroundColor || colors.secondary,
        border: `2px solid ${isSelected ? colors.color || colors.primary : `${colors.color || colors.primary}20`}`,
        transition: 'all 0.2s ease-in-out',
        position: 'relative',
        cursor: onClick ? 'pointer' : 'default',
        transform: 'scale(1)',
        '&:hover': onClick
          ? {
              transform: 'scale(1.02)',
              boxShadow: 4,
            }
          : {},
        '&:active': onClick
          ? {
              transform: 'scale(0.98)',
              boxShadow: 2,
            }
          : {},
        ...sx,
      }}
    >
      <CardContent sx={{ p: 2, pb: 2 }}>
        {/* 頂部區域 */}
        <Box
          sx={{
            display: 'flex',
            justifyContent: showIcon ? 'flex-start' : 'space-between',
            alignItems: showIcon ? 'center' : 'flex-start',
            mb: 1,
            gap: showIcon ? 1 : 0,
          }}
        >
          {/* 保固種類 Chip (左上角) - 只有保固金種類顯示 */}
          {ensureType && (
            <Chip
              icon={colors.icon}
              label={ensureType}
              variant="outlined"
              size="small"
              sx={{
                borderColor: colors.color,
                color: colors.color,
                backgroundColor: 'rgba(255,255,255,0.8)',
                fontSize: '11px',
                height: '20px',
                '& .MuiChip-icon': {
                  color: colors.color,
                  fontSize: '14px !important',
                },
                '& .MuiChip-label': {
                  px: 0.5,
                  fontWeight: 600,
                },
              }}
            />
          )}

          {/* 圖標和標題 - 整體保固狀況水平排列 */}
          {showIcon && (
            <>
              <Box
                sx={{
                  width: 32,
                  height: 32,
                  borderRadius: '8px',
                  backgroundColor: colors.color || colors.primary,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: 'white',
                  flexShrink: 0,
                  '& svg': { fontSize: '18px' },
                }}
              >
                <FunctionsIcon />
              </Box>
              <Typography
                variant="body2"
                sx={{
                  fontWeight: 600,
                  color: colors.color || colors.primary,
                  fontSize: '13px',
                  lineHeight: 1.2,
                }}
              >
                {title}
              </Typography>
            </>
          )}
        </Box>

        {/* 標題 - 只有保固金種類顯示 */}
        {!showIcon && title && (
          <Typography
            variant="body2"
            sx={{
              fontWeight: 600,
              color: colors.color || colors.primary,
              fontSize: '13px',
            }}
          >
            {title}
          </Typography>
        )}

        {/* 主要數值顯示 - 兩行資料 */}
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5 }}>
          {/* 第一行：筆數資料 */}
          <Box
            sx={{
              display: 'flex',
              alignItems: 'baseline',
              gap: 0.5,
              flexDirection: 'column',
            }}
          >
            <Typography
              variant="body2"
              sx={{
                color: colors.color || colors.primary,
                opacity: 0.8,
                fontWeight: 600,
                fontSize: '11px',
                minWidth: 'fit-content',
              }}
            >
              未解除保固筆數
            </Typography>
            <Box
              sx={{
                display: 'flex',
                alignItems: 'baseline',
                width: '100%',
                justifyContent: 'center',
              }}
            >
              <Typography
                variant="h6"
                sx={{
                  fontWeight: 700,
                  color: colors.color || colors.primary,
                  lineHeight: 1.2,
                  fontSize: '24px',
                }}
              >
                {formatCount(countData.total)}
              </Typography>
            </Box>
          </Box>

          {/* 第二行：金額資料 */}
          <Box
            sx={{
              display: 'flex',
              alignItems: 'baseline',
              gap: 0.5,
              flexDirection: 'column',
            }}
          >
            <Typography
              variant="body2"
              sx={{
                color: colors.color || colors.primary,
                opacity: 0.8,
                fontWeight: 600,
                fontSize: '11px',
                minWidth: 'fit-content',
              }}
            >
              未解除保固金額
            </Typography>
            <Box
              sx={{
                display: 'flex',
                alignItems: 'baseline',
                width: '100%',
                justifyContent: 'center',
              }}
            >
              <Typography
                variant="h6"
                sx={{
                  fontWeight: 700,
                  color: colors.color || colors.primary,
                  lineHeight: 1.2,
                  fontSize: '24px',
                }}
              >
                {formatAmount(amountData.total)}
              </Typography>
            </Box>
          </Box>
        </Box>
      </CardContent>
    </Card>
  )
}
