import { defineConfig } from 'astro/config'
import tailwind from '@astrojs/tailwind'
import react from '@astrojs/react'

export default defineConfig({
  site: 'https://ykts.net',
  output: 'static',
  vite: {
    ssr: {
      external: ['node:fs', 'node:path'],
    },
  },
  integrations: [tailwind(), react()],
})
