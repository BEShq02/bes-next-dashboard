import { tables } from '@/lib/tables'
import { redirect } from 'next/navigation'
import WeeklyReportClient from './components/WeeklyReportClient'

export default async function WeeklyReport({ searchParams }) {
  const { ORD_NO: ordNo, fromAdmin, token } = await searchParams
  const ordNoC = await tables.sysAccessToken.getOrdNo()
  
  // 只有當 fromAdmin=true 時才允許跳過驗證（從 admin 頁面來的）
  if (fromAdmin === 'true' && ordNo) {
    return <WeeklyReportClient skipAuth={true} adminOrdNo={ordNo} />
  }
  
  // 如果只有 token 而沒有 ORD_NO，從資料庫查詢 ORD_NO
  if (token && !ordNo) {
    try {
      const ordNoFromToken = await tables.sysAccessToken.getOrdNoByToken(token)
      if (ordNoFromToken) {
        // 重定向到包含 ORD_NO 的 URL
        redirect(`/weekly-report?token=${encodeURIComponent(token)}&ORD_NO=${encodeURIComponent(ordNoFromToken)}`)
      }
    } catch (error) {
      console.error('從 token 取得 ORD_NO 失敗:', error)
    }
  }
  
  // 其他情況都需要 token 驗證
  return <WeeklyReportClient ordNoC={ordNoC} />
}

export async function generateMetadata({ searchParams }) {
  const { ORD_NO: ordNo } = await searchParams
  const defaultSiteName = '工務所'
  const defaultOrdCh = '工令'

  if (!ordNo) {
    return {
      title: `${defaultSiteName} - ${defaultOrdCh}`,
    }
  }

  let siteName = defaultSiteName
  let ordCh = defaultOrdCh

  try {
    const wkMainData = await tables.wkMain.getData(ordNo)
    siteName = wkMainData[0]?.SITE_CNAME || defaultSiteName
    ordCh = wkMainData[0]?.ORD_CH || defaultOrdCh
  } catch (error) {
    console.error('取得工務所名稱失敗:', error)
  } finally {
    return {
      title: `${siteName} - ${ordCh}`,
    }
  }
}
