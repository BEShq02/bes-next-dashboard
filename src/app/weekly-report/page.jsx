import { tables } from '@/lib/tables'
import WeeklyReportClient from './components/WeeklyReportClient'

export default async function WeeklyReport() {
  const ordNoC = await tables.sysAccessToken.getOrdNo()
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
