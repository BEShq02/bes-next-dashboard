'use client'

import Box from '@mui/material/Box'
import Chip from '@mui/material/Chip'
import Typography from '@mui/material/Typography'
import DownloadIcon from '@mui/icons-material/Download'
export default function Footer() {
  const handleDownloadClick = () => {
    // Chrome Web Store的goFullPage擴充功能網址
    const goFullPageUrl =
      'https://chrome.google.com/webstore/detail/gofullpage-full-page-scre/fdpohaocaechififmbbbbbknoalclacl'
    window.open(goFullPageUrl, '_blank')
  }

  return (
    <Box sx={{ width: '100%', textAlign: 'center', pt: 4 }}>
      <Typography variant="body2" color="text.secondary">
        中華工程 影音即時指揮中心開發
      </Typography>
      <Chip
        label="安裝Chrome網頁長截圖擴充功能"
        clickable
        onClick={handleDownloadClick}
        onDelete={handleDownloadClick}
        deleteIcon={<DownloadIcon />}
        variant="outlined"
        size="small"
        sx={{ border: 'none', color: 'text.secondary' }}
      />
    </Box>
  )
}
