/**
 * 收藏页展示模型定义。
 */

import { TrainingType } from '../../../domain/static/train/TrainingRuntimeTypes'

/**
 * 收藏页列表项读模型。
 */
export interface FavoriteDisplayItem {
  /** 列表项唯一标识。 */
  id: string
  /** 训练项编码（课程项为空）。 */
  itemCode: string
  /** 主标题。 */
  title: string
  /** 副标题。 */
  subtitle: string
  /** 所属课程编码。 */
  courseCode: string
  /** 所属课程名称。 */
  courseName: string
  /** 训练类型。 */
  trainingType: TrainingType
  /** 可选补充短句。 */
  phrase: string
  /** 项目类型。 */
  kind: 'course' | 'item'
}

/**
 * 收藏页头部读模型。
 */
export interface FavoritePageHeaderView {
  /** 头像地址。 */
  avatarUrl: string
  /** 展示昵称。 */
  nickname: string
  /** 已收藏课程数量。 */
  favoriteCourseCount: number
}
