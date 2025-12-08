import { tables } from '@/lib/tables'

import EnsureTable from './components/EnsureTable'

export default async function Or80() {
  const wkEnsureData = await tables.wkEnsure.getData()
  const wkEnsureDescData = await tables.wkEnsureDesc.getData()
  console.log(wkEnsureData)
  return (
    <div style={{ padding: 16 }}>
      <EnsureTable data={wkEnsureData} descData={wkEnsureDescData} />
    </div>
  )
}
