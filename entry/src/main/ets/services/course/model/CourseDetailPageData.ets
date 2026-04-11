/**
 * 课程详情页视图数据。
 */
import { DEFAULT_COURSE_COVER_URL } from '../../../config/AppConfig'
import { TrainingContentItem } from '../../../domain/static/train/TrainingContentModels'
import { TrainItemStatus, TrainingType } from '../../../domain/static/train/TrainingRuntimeTypes'

export class CourseDetailPageData {
  /** 路由入参中的课程编码，整条加载链路的主键。 */
  courseCode: string = ''
  /** 来自课程详情/预览缓存或详情接口。 */
  courseName: string = '课程详情'
  courseIntro: string = ''
  coverUrl: string = DEFAULT_COURSE_COVER_URL
  trainingType: TrainingType = 'gesture'
  tags: string[] = []
  /** 训练项列表：优先详情缓存，回退预览，再可由会话详情映射补齐。 */
  courseItems: TrainingContentItem[] = []
  completedItemIds: number[] = []
  currentItemIndex: number = -1
  currentItemStatus: TrainItemStatus = ''
  currentItemCode: string = ''
  /** 会话进度聚合字段：主要来自 CourseSessionCache。 */
  sessionProgressPercent: number = 0
  completedItemCount: number = 0
  totalItemCount: number = 0
  /** 页面级提示文案（加载中/失败提示）。 */
  detailTip: string = ''
}
