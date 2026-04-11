/**
 * 课程会话训练项视图模型。
 */
import { TrainingContentItem } from '../../../domain/static/train/TrainingContentModels'
import { TrainItemStatus } from '../../../domain/static/train/TrainingRuntimeTypes'

export class CourseSessionItemsViewModel {
  /** 由课程会话快照映射得到的训练项列表。 */
  courseItems: TrainingContentItem[] = []
  /** 会话中已完成训练项 id 列表。 */
  completedItemIds: number[] = []
  /** 当前训练项在列表中的索引。 */
  currentItemIndex: number = -1
  /** 当前训练项状态。 */
  currentItemStatus: TrainItemStatus = ''
}
