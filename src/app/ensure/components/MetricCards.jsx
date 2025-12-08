'use client'

import { useMemo, useState, useEffect } from 'react'

import { Box, Grid } from '@mui/material'

import MetricCard from './MetricCard'

/**
 * 指標卡片容器組件
 * @param {Object} props
 * @param {Array} props.data - 保固數據陣列
 * @param {string} props.siteFilter - 當前的工務所篩選條件（保留用於向後兼容，但不影響卡片數據）
 * @param {Function} props.onCardClick - 卡片點擊處理函數，參數為保固金種類（null 表示全部）
 * @param {string|null} props.selectedEnsureType - 當前選中的保固金種類
 */
export default function MetricCards({
  data = [],
  siteFilter: _siteFilter = '', // 保留但不使用，卡片數據始終顯示全部資料
  onCardClick,
  selectedEnsureType = undefined,
}) {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  // 判斷是否為未解除保固的項目（STOP_ENSURE_DATE 為空、null、undefined 或空字串）
  const isNotStopped = row => {
    const stopDate = row.STOP_ENSURE_DATE
    return !stopDate || stopDate === '' || stopDate === null || stopDate === undefined
  }

  // 判斷是否為未過保的項目（IS_EXPIRED 不等於 'Y'）
  const isNotExpired = row => {
    return row.IS_EXPIRED !== 'Y'
  }

  // 根據篩選條件過濾數據，只包含未解除保固的項目
  // 注意：卡片數據不受 siteFilter 影響，始終顯示全部資料的統計
  const filteredData = useMemo(() => {
    return data.filter(isNotStopped)
  }, [data])

  // 計算總體統計數據（未過保）
  const overallStats = useMemo(() => {
    const totalCount = filteredData.length
    const notExpiredCount = filteredData.filter(isNotExpired).length
    const totalAmount = filteredData.reduce((sum, row) => {
      const amount = parseFloat(row.ENSURE_AMOUNT || 0)
      return sum + (isNaN(amount) ? 0 : amount)
    }, 0)
    const notExpiredAmount = filteredData.filter(isNotExpired).reduce((sum, row) => {
      const amount = parseFloat(row.ENSURE_AMOUNT || 0)
      return sum + (isNaN(amount) ? 0 : amount)
    }, 0)

    return {
      count: { expired: notExpiredCount, total: totalCount },
      amount: { expired: notExpiredAmount, total: totalAmount },
    }
  }, [filteredData])

  // 計算各保固金種類的統計數據（未過保）
  const ensureTypeStats = useMemo(() => {
    const ensureTypes = ['定存單', '現金', '保證書', '切結書']

    return ensureTypes.map(type => {
      const typeData = filteredData.filter(row => row.ENSURE_CH === type)
      const notExpiredTypeData = typeData.filter(isNotExpired)

      // 筆數統計
      const totalCount = typeData.length
      const notExpiredCount = notExpiredTypeData.length

      // 金額統計
      const totalAmount = typeData.reduce((sum, row) => {
        const amount = parseFloat(row.ENSURE_AMOUNT || 0)
        return sum + (isNaN(amount) ? 0 : amount)
      }, 0)
      const notExpiredAmount = notExpiredTypeData.reduce((sum, row) => {
        const amount = parseFloat(row.ENSURE_AMOUNT || 0)
        return sum + (isNaN(amount) ? 0 : amount)
      }, 0)

      return {
        type,
        count: { expired: notExpiredCount, total: totalCount },
        amount: { expired: notExpiredAmount, total: totalAmount },
      }
    })
  }, [filteredData])

  if (!mounted) {
    return (
      <Box sx={{ mb: 2 }} suppressHydrationWarning>
        {/* 指標卡片網格 - 響應式設計 */}
        <Grid container spacing={2} sx={{ width: '100%' }}>
          {/* 第一張卡片：總體統計 */}
          <Grid size={{ xs: 12, sm: 6, md: 4, lg: 2.4 }}>
            <MetricCard
              title="整體未解除保固狀況"
              countData={overallStats.count}
              amountData={overallStats.amount}
              showIcon={true}
              onClick={() => onCardClick && onCardClick(null)}
              isSelected={selectedEnsureType === null}
              sx={{ height: '100%', width: '100%' }}
            />
          </Grid>

          {/* 第二到五張卡片：各保固金種類 */}
          {ensureTypeStats.map(stat => (
            <Grid size={{ xs: 12, sm: 6, md: 4, lg: 2.4 }} key={stat.type}>
              <MetricCard
                title={null}
                countData={stat.count}
                amountData={stat.amount}
                ensureType={stat.type}
                onClick={() => onCardClick && onCardClick(stat.type)}
                isSelected={selectedEnsureType === stat.type}
                sx={{ height: '100%', width: '100%' }}
              />
            </Grid>
          ))}
        </Grid>
      </Box>
    )
  }

  return (
    <Box sx={{ mb: 2 }}>
      {/* 指標卡片網格 - 響應式設計 */}
      <Grid container spacing={2} sx={{ width: '100%' }}>
        {/* 第一張卡片：總體統計 */}
        <Grid size={{ xs: 12, sm: 6, md: 4, lg: 2.4 }}>
          <MetricCard
            title="整體未解除保固狀況"
            countData={overallStats.count}
            amountData={overallStats.amount}
            showIcon={true}
            onClick={() => onCardClick && onCardClick(null)}
            isSelected={selectedEnsureType === null}
            sx={{ height: '100%', width: '100%' }}
          />
        </Grid>

        {/* 第二到五張卡片：各保固金種類 */}
        {ensureTypeStats.map(stat => (
          <Grid size={{ xs: 12, sm: 6, md: 4, lg: 2.4 }} key={stat.type}>
            <MetricCard
              title={null}
              countData={stat.count}
              amountData={stat.amount}
              ensureType={stat.type}
              onClick={() => onCardClick && onCardClick(stat.type)}
              isSelected={selectedEnsureType === stat.type}
              sx={{ height: '100%', width: '100%' }}
            />
          </Grid>
        ))}
      </Grid>
    </Box>
  )
}
