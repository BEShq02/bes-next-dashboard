import { Box } from '@mui/material'

import NavBar from './components/NavBar'

export const metadata = {
  title: '工程工務處 | 保固管控',
  description: '保固管控系統',
}

export default function Or80Layout({ children }) {
  return (
    <Box
      sx={{
        minHeight: '100vh',
        background: 'linear-gradient(135deg, #f5f7fa 0%, #e8ecf1 100%)',
        backgroundAttachment: 'fixed',
      }}
    >
      <NavBar />
      <Box sx={{ position: 'relative', zIndex: 1 }}>{children}</Box>
    </Box>
  )
}
