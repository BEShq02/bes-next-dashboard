import db from '@/lib/db'

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url)
    const ordNo = searchParams.get('ORD_NO')

    if (!ordNo) {
      return Response.json(
        {
          error: '缺少 ORD_NO 參數',
          message: '請在 URL 中提供 ORD_NO 參數，例如：/api/test?ORD_NO=your_value',
        },
        { status: 400 }
      )
    }

    // 更新 [STAGE].[dbo].[SYS_ACCESS_TOKEN] 表中 ID 為 30805 的記錄的 ORD_NO 欄位
    const updateQuery = `
      UPDATE [STAGE].[dbo].[SYS_ACCESS_TOKEN] 
      SET ORD_NO = @ordNo 
      WHERE ID = @id
    `

    const params = {
      ordNo: ordNo,
      id: 30805,
    }

    await db.query(updateQuery, params)

    return Response.json({
      success: true,
      message: `成功更新 ORD_NO 為：${ordNo}`,
      data: {
        id: 30805,
        ordNo: ordNo,
        updatedAt: new Date().toISOString(),
      },
    })
  } catch (error) {
    console.error('API 錯誤:', error)
    return Response.json(
      {
        error: '資料庫更新失敗',
        message: error.message,
      },
      { status: 500 }
    )
  }
}
