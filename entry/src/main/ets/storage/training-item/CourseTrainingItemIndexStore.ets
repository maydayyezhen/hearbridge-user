/** 课程与训练项索引缓存表，按课程编码索引训练项缓存键列表。 */
const COURSE_ITEM_INDEX_CACHE: Map<string, string[]> = new Map()

/**
 * 初始化课程训练项索引 Store。
 */
export function initCourseTrainingItemIndexStore(): void {}

/**
 * 覆盖写入课程与训练项的索引关系。
 * @param courseCode 课程编码。
 * @param nextKeys 新的训练项缓存键列表。
 */
export function ensureCourseItemIndex(courseCode: string, nextKeys: string[]): void {
  COURSE_ITEM_INDEX_CACHE.set(courseCode, [...nextKeys])
}

/**
 * 向课程与训练项索引中追加单个训练项键。
 * @param courseCode 课程编码。
 * @param key 训练项缓存键。
 */
export function appendCourseItemKey(courseCode: string, key: string): void {
  const current = COURSE_ITEM_INDEX_CACHE.get(courseCode) ?? []
  if (!current.includes(key)) {
    current.push(key)
    COURSE_ITEM_INDEX_CACHE.set(courseCode, current)
  }
}

/**
 * 读取课程下的训练项缓存键列表。
 * @param courseCode 课程编码。
 * @returns 训练项缓存键列表。
 */
export function getCourseTrainingItemCodes(courseCode: string): string[] {
  return [...(COURSE_ITEM_INDEX_CACHE.get(courseCode) ?? [])]
}

/**
 * 清空课程与训练项索引缓存。
 */
export function clearCourseTrainingItemIndexCache(): void {
  COURSE_ITEM_INDEX_CACHE.clear()
}
