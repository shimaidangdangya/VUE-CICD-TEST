import { readdirSync, readFileSync } from 'node:fs'
import { gzipSync } from 'node:zlib'
import path from 'node:path'

const DIR = 'dist/assets'
const BUDGET_KB = 1500

let names = []
try {
  names = readdirSync(DIR)
} catch {
  console.error(`❌ 找不到 ${DIR} 目录，请先执行 pnpm run build`)
  process.exit(1)
}

let total = 0
for (const n of names.filter((n) => /\.(js|css)$/.test(n))) {
  const kb = gzipSync(readFileSync(path.join(DIR, n))).length / 1024
  total += kb
  console.log(`  ${n.padEnd(40)} ${kb.toFixed(1).padStart(8)} KB`)
}

console.log(`\n总计（gzip 压缩后）：${total.toFixed(1)} KB，预算 ${BUDGET_KB} KB`)
if (total > BUDGET_KB) {
  console.error('❌ 超出预算，请优化后再提交')
  process.exit(1)
}
console.log('✅ 体积在预算内')