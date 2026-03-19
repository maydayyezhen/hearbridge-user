import { TrainingItemDetailData, TrainingSessionItemDto, TrainingResourceDto } from '../../api/TrainingApi'

export class MediaResourceItem {
  uid: string
  name: string
  url: string
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

export class TrainingItem {
  id: number
  name: string
  code: string
  majorCategoryCode: string
  levelNum: number
  isRecommended: boolean
  sortNum: number
  status: string
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
    sortNum: number, status: string, meaning: string, description: string, goal: string, precautions: string[],
    commonErrors: string[], cover: MediaResourceItem[], video: MediaResourceItem[], audio: MediaResourceItem[],
    actionImages: MediaResourceItem[], videoPoster: MediaResourceItem[]) {
    this.id = id
    this.name = name
    this.code = code
    this.majorCategoryCode = majorCategoryCode
    this.levelNum = levelNum
    this.isRecommended = isRecommended
    this.sortNum = sortNum
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

function mapResources(resources: TrainingResourceDto[], resourceType: string): MediaResourceItem[] {
  const result: MediaResourceItem[] = []
  for (let i = 0; i < resources.length; i += 1) {
    if (resources[i].resourceType === resourceType) {
      result.push(new MediaResourceItem(
        `${resourceType}_${i + 1}`,
        resources[i].fileName,
        resources[i].fileUrl,
        'done'
      ))
    }
  }
  return result
}

function mapActionImages(resources: TrainingResourceDto[]): MediaResourceItem[] {
  const result: MediaResourceItem[] = []
  let index = 0
  for (let i = 0; i < resources.length; i += 1) {
    if (resources[i].resourceType === 'action_image') {
      result.push(new MediaResourceItem(
        `action_${index + 1}`,
        resources[i].fileName,
        resources[i].fileUrl,
        'done'
      ))
      index += 1
    }
  }
  return result
}

export function mapSessionItemToTrainingItem(item: TrainingSessionItemDto, trainingType: string, index: number): TrainingItem {
  const normalizedType = trainingType === 'voice' ? 'voice' : 'gesture'
  return new TrainingItem(
    index + 1,
    item.itemName,
    item.itemCode,
    normalizedType,
    item.levelNum,
    false,
    item.itemOrder,
    item.status,
    '',
    '',
    '',
    [],
    [],
    [],
    [],
    [],
    [],
    []
  )
}

export function mapTrainingItemDetailToTrainingItem(item: TrainingItemDetailData, trainingType: string, index: number): TrainingItem {
  const normalizedType = trainingType === 'voice' ? 'voice' : 'gesture'
  return new TrainingItem(
    index + 1,
    item.itemName,
    item.itemCode,
    normalizedType,
    item.levelNum,
    false,
    item.itemOrder,
    item.status,
    item.meaning,
    item.description,
    item.goal,
    item.precautions,
    item.commonErrors,
    mapResources(item.resources, 'cover'),
    mapResources(item.resources, 'video'),
    mapResources(item.resources, 'audio'),
    mapActionImages(item.resources),
    mapResources(item.resources, 'video_poster')
  )
}
