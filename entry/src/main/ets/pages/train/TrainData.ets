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

export const FALLBACK_COVER_URL: string = 'http://192.168.142.128:9001/hearbridge-bucket/20260316/3ad909fc0af94c58a8f2be4ca2fe4cbcChatGPT%20Image%202026%E5%B9%B43%E6%9C%8816%E6%97%A5%2001_25_49.png'

export function getMockTrainingItems(): TrainingItem[] {
  return [
    new TrainingItem(
      1, '你好', 'GESTURE_HELLO', 'gesture', 3, true, 10, 'published',
      '用于日常问候场景。', '抬起右手，掌心朝外，轻微摆动。', '帮助学员完成基础问候表达。',
      ['手掌方向朝外', '动作幅度自然'], ['手掌方向错误'],
      [new MediaResourceItem('g-cover-1', 'cover-hello.png', 'https://placehold.co/400x240/png?text=Hello', 'done')],
      [new MediaResourceItem('g-video-1', 'hello-demo.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 'done')],
      [],
      [
        new MediaResourceItem('g-step-1', 'hello-step-1.png', 'https://placehold.co/200x200/png?text=Hello+1', 'done', '抬手准备', '右手自然抬起，手臂不要僵硬，准备进入问候动作。'),
        new MediaResourceItem('g-step-2', 'hello-step-2.png', 'https://placehold.co/200x200/png?text=Hello+2', 'done', '掌心朝外', '保持掌心朝外，轻微摆动，动作幅度自然即可。')
      ],
      []
    ),
    new TrainingItem(
      3, '阿', 'VOICE_A', 'voice', 1, true, 10, 'published',
      '用于学习基础元音发音。', '张口自然，保持声音平稳输出。', '帮助学员完成元音发音入门训练。',
      ['口型自然张开', '发音时长稳定'], ['发音过短', '口型过紧'],
      [new MediaResourceItem('v-cover-1', 'cover-voice-a.png', 'https://placehold.co/400x240/png?text=Voice+A', 'done')],
      [new MediaResourceItem('v-video-1', 'voice-a-demo.mp4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 'done')],
      [new MediaResourceItem('v-audio-1', 'voice-a.mp3', 'https://www.w3schools.com/html/horse.mp3', 'done')],
      [
        new MediaResourceItem('v-step-1', 'voice-a-mouth-1.png', 'https://placehold.co/200x200/png?text=Voice+A+1', 'done', '张口准备', '嘴巴自然张开，面部放松，不要刻意用力。'),
        new MediaResourceItem('v-step-2', 'voice-a-mouth-2.png', 'https://placehold.co/200x200/png?text=Voice+A+2', 'done', '稳定发音', '保持口型稳定，均匀发出阿的声音。')
      ],
      []
    ),
    new TrainingItem(
      6, '你好', 'VOI_001', 'voice', 1, true, 10, 'enabled',
      '你好', '先看口型，再跟随视频完成模仿练习。', '帮助学员掌握“你好”的发音节奏。',
      ['先看口型再发音', '保持语速平稳'], ['尾音不清晰'],
      [new MediaResourceItem('v-cover-2', 'cover-voice-hello.png', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/nihao.png', 'done')],
      [new MediaResourceItem('v-video-2', '%E4%BD%A0%E5%A5%BD.mp4', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/7375fc2d133c4ffdb11ed159fefd7a24%E4%BD%A0%E5%A5%BD.mp4', 'done')],
      [new MediaResourceItem('v-audio-2', 'nihao.mp3', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/nihao.mp3', 'done')],
      [
        new MediaResourceItem(
          'v-step-1',
          'step-1.jpg',
          'http://192.168.142.128:9001/hearbridge-bucket/20260316/ni.png',
          'done',
          '第一步',
          '嘴角自然打开'
        ),
        new MediaResourceItem(
          'v-step-2',
          'step-2.jpg',
          'http://192.168.142.128:9001/hearbridge-bucket/20260316/hao.png',
          'done',
          '第二步',
          '舌尖轻抵下齿'
        )
      ],
      [new MediaResourceItem('v-poster-2', 'video-cover-1773594512063.png', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/76b784b8925d45deb0afdb109387ad35video-cover-1773594511837.png', 'done')]
    ),
    new TrainingItem(
      7, '你好-节奏版', 'VOI_002', 'voice', 2, true, 20, 'enabled',
      '强化中段节奏控制。', '重点训练“你-好”之间的停连与节奏稳定。', '让发音节奏更自然，避免前快后慢。',
      ['先慢后快', '保持尾音稳定'], ['中段断开过明显'],
      [new MediaResourceItem('v-cover-3', 'cover-voice-rhythm.png', 'https://placehold.co/1280x720/png?text=Nihao+Rhythm+Drill', 'done')],
      [new MediaResourceItem('v-video-3', 'nihao-rhythm.mp4', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/7375fc2d133c4ffdb11ed159fefd7a24%E4%BD%A0%E5%A5%BD.mp4', 'done')],
      [new MediaResourceItem('v-audio-3', 'nihao-rhythm.mp3', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/nihao.mp3', 'done')],
      [
        new MediaResourceItem('v-step-3-1', 'rhythm-step-1.jpg', 'https://placehold.co/480x480/png?text=Rhythm+Step+1', 'done', '动作提示', '先把“你”读稳，再平滑过渡到“好”。'),
        new MediaResourceItem('v-step-3-2', 'rhythm-step-2.jpg', 'https://placehold.co/480x480/png?text=Rhythm+Step+2', 'done', '动作提示', '尾音拉满但不要拖长，保持干净收尾。')
      ],
      [new MediaResourceItem('v-poster-3', 'video-cover-rhythm.png', 'https://placehold.co/720x1280/png?text=Rhythm+Poster', 'done')]
    ),
    new TrainingItem(
      8, '你好-强化版', 'VOI_003', 'voice', 3, false, 30, 'enabled',
      '综合强化清晰度与力度。', '在稳定节奏下提升发音清晰度和完成度。', '形成可复用的“你好”发音模板。',
      ['起音清晰', '尾音收紧'], ['语速偏快导致含混'],
      [new MediaResourceItem('v-cover-4', 'cover-voice-advanced.png', 'https://placehold.co/1280x720/png?text=Nihao+Advanced+Drill', 'done')],
      [new MediaResourceItem('v-video-4', 'nihao-advanced.mp4', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/7375fc2d133c4ffdb11ed159fefd7a24%E4%BD%A0%E5%A5%BD.mp4', 'done')],
      [new MediaResourceItem('v-audio-4', 'nihao-advanced.mp3', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/nihao.mp3', 'done')],
      [
        new MediaResourceItem('v-step-4-1', 'advanced-step-1.jpg', 'https://placehold.co/480x480/png?text=Advanced+Step+1', 'done', '动作提示', '口型打开到位，起音瞬间要清楚。'),
        new MediaResourceItem('v-step-4-2', 'advanced-step-2.jpg', 'https://placehold.co/480x480/png?text=Advanced+Step+2', 'done', '动作提示', '“好”收尾更集中，避免漏气。')
      ],
      [new MediaResourceItem('v-poster-4', 'video-cover-advanced.png', 'https://placehold.co/720x1280/png?text=Advanced+Poster', 'done')]
    )
  ]
}
