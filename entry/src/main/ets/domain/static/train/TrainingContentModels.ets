/**
 * TrainingContentModels 文件，负责训练内容展示模型定义。
 */
import { TrainItemStatus } from './TrainingRuntimeTypes'

export class MediaResourceItem {
  uid: string
  name: string
  url: string
  /**
   * 媒体资源状态，表示资源加载 / 可用性状态，不等同于训练流程状态。
   */
  status: string
  title: string
  description: string

  constructor(uid: string, name: string, url: string, status: string, title: string = '', description: string = '') {
    this.uid = uid
    this.name = name
    this.url = url
    this.status = status
    this.title = title
    this.description = description
  }
}

/** TrainingContentItem。 */
export class TrainingContentItem {
  id: number
  name: string
  code: string
  majorCategoryCode: string
  levelNum: number
  isRecommended: boolean
  itemOrder: number
  score: number
  status: TrainItemStatus
  meaning: string
  description: string
  goal: string
  precautions: string[]
  commonErrors: string[]
  cover: MediaResourceItem[]
  video: MediaResourceItem[]
  audio: MediaResourceItem[]
  actionImages: MediaResourceItem[]
  videoPoster: MediaResourceItem[]

  constructor(id: number, name: string, code: string, majorCategoryCode: string, levelNum: number, isRecommended: boolean,
    itemOrder: number, score: number, status: TrainItemStatus, meaning: string, description: string, goal: string, precautions: string[],
    commonErrors: string[], cover: MediaResourceItem[], video: MediaResourceItem[], audio: MediaResourceItem[],
    actionImages: MediaResourceItem[], videoPoster: MediaResourceItem[]) {
    this.id = id
    this.name = name
    this.code = code
    this.majorCategoryCode = majorCategoryCode
    this.levelNum = levelNum
    this.isRecommended = isRecommended
    this.itemOrder = itemOrder
    this.score = score
    this.status = status
    this.meaning = meaning
    this.description = description
    this.goal = goal
    this.precautions = precautions
    this.commonErrors = commonErrors
    this.cover = cover
    this.video = video
    this.audio = audio
    this.actionImages = actionImages
    this.videoPoster = videoPoster
  }
}

/** createTrainingContentItemByPatch。 */
export function createTrainingContentItemByPatch(patch: Partial<TrainingContentItem>): TrainingContentItem {
  const item = new TrainingContentItem(0, '', '', '', 1, false, 0, 0, '', '', '', '', [], [], [], [], [], [], [])
  item.id = patch.id ?? item.id
  item.name = patch.name ?? item.name
  item.code = patch.code ?? item.code
  item.majorCategoryCode = patch.majorCategoryCode ?? item.majorCategoryCode
  item.levelNum = patch.levelNum ?? item.levelNum
  item.isRecommended = patch.isRecommended ?? item.isRecommended
  item.itemOrder = patch.itemOrder ?? item.itemOrder
  item.score = patch.score ?? item.score
  item.status = patch.status ?? item.status
  item.meaning = patch.meaning ?? item.meaning
  item.description = patch.description ?? item.description
  item.goal = patch.goal ?? item.goal
  item.precautions = patch.precautions ? [...patch.precautions] : item.precautions
  item.commonErrors = patch.commonErrors ? [...patch.commonErrors] : item.commonErrors
  item.cover = patch.cover ? [...patch.cover] : item.cover
  item.video = patch.video ? [...patch.video] : item.video
  item.audio = patch.audio ? [...patch.audio] : item.audio
  item.actionImages = patch.actionImages ? [...patch.actionImages] : item.actionImages
  item.videoPoster = patch.videoPoster ? [...patch.videoPoster] : item.videoPoster
  return item
}
