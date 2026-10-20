import {describe, it, expect} from 'vitest'

describe('先证明测试能跑', () => {
  it('1 + 1 等于 2', () => {
    expect(1 + 1).toBe(2)
  })

  it('字符串长度是 5', () => {
    expect('hello').toHaveLength(5)
  })
})