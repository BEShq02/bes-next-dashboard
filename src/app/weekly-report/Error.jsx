import { ICCC_URL } from '@/config-global'

import { Alert, Button } from '@mui/material'

export default function Error({ message }) {
  return (
    <>
      <Alert severity="error">{message}</Alert>

      <Button
        href={ICCC_URL}
        variant="contained"
        size="large"
        color="error"
        sx={{
          position: 'absolute',
          top: '50%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
        }}
      >
        返回 影音即時指揮中心 - 智慧決策平台
      </Button>
    </>
  )
}
