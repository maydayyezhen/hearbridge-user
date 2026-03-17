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
    ),
    new TrainingItem(
      9, '口型稳定 1', 'VOI_004', 'voice', 1, false, 40, 'enabled',
      '口型基础稳定练习。', '先慢速发音，观察嘴角与下颌开合。', '建立稳定口型控制能力。',
      ['慢速起音', '保持口型'], ['口型忽大忽小'],
      [new MediaResourceItem('v-cover-5', 'cover-voi-004.png', 'https://placehold.co/1280x720/png?text=VOI_004', 'done')],
      [new MediaResourceItem('v-video-5', 'voi-004.mp4', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/7375fc2d133c4ffdb11ed159fefd7a24%E4%BD%A0%E5%A5%BD.mp4', 'done')],
      [new MediaResourceItem('v-audio-5', 'voi-004.mp3', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/nihao.mp3', 'done')],
      [
        new MediaResourceItem('v-step-5-1', 'step-1.png', 'https://placehold.co/480x480/png?text=VOI_004+S1', 'done', '动作提示', '保持嘴角自然打开。'),
        new MediaResourceItem('v-step-5-2', 'step-2.png', 'https://placehold.co/480x480/png?text=VOI_004+S2', 'done', '动作提示', '尾音收束不要拖长。')
      ],
      [new MediaResourceItem('v-poster-5', 'poster-voi-004.png', 'https://placehold.co/720x1280/png?text=VOI_004+Poster', 'done')]
    ),
    new TrainingItem(
      10, '口型稳定 2', 'VOI_005', 'voice', 1, false, 50, 'enabled',
      '连续发音稳定训练。', '维持节奏，避免中间停顿。', '提升连续发音流畅度。',
      ['节奏均匀', '气息平稳'], ['中断明显'],
      [new MediaResourceItem('v-cover-6', 'cover-voi-005.png', 'https://placehold.co/1280x720/png?text=VOI_005', 'done')],
      [new MediaResourceItem('v-video-6', 'voi-005.mp4', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/7375fc2d133c4ffdb11ed159fefd7a24%E4%BD%A0%E5%A5%BD.mp4', 'done')],
      [new MediaResourceItem('v-audio-6', 'voi-005.mp3', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/nihao.mp3', 'done')],
      [
        new MediaResourceItem('v-step-6-1', 'step-1.png', 'https://placehold.co/480x480/png?text=VOI_005+S1', 'done', '动作提示', '起音轻，口型稳。'),
        new MediaResourceItem('v-step-6-2', 'step-2.png', 'https://placehold.co/480x480/png?text=VOI_005+S2', 'done', '动作提示', '尾音集中收紧。')
      ],
      [new MediaResourceItem('v-poster-6', 'poster-voi-005.png', 'https://placehold.co/720x1280/png?text=VOI_005+Poster', 'done')]
    ),
    new TrainingItem(
      11, '节奏控制 1', 'VOI_006', 'voice', 2, true, 60, 'enabled',
      '节奏分段控制。', '掌握起音与尾音之间的停连。', '形成稳定节奏感。',
      ['先慢后快', '分段清晰'], ['节奏前快后慢'],
      [new MediaResourceItem('v-cover-7', 'cover-voi-006.png', 'https://placehold.co/1280x720/png?text=VOI_006', 'done')],
      [new MediaResourceItem('v-video-7', 'voi-006.mp4', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/7375fc2d133c4ffdb11ed159fefd7a24%E4%BD%A0%E5%A5%BD.mp4', 'done')],
      [new MediaResourceItem('v-audio-7', 'voi-006.mp3', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/nihao.mp3', 'done')],
      [
        new MediaResourceItem('v-step-7-1', 'step-1.png', 'https://placehold.co/480x480/png?text=VOI_006+S1', 'done', '动作提示', '第一段保持稳定。'),
        new MediaResourceItem('v-step-7-2', 'step-2.png', 'https://placehold.co/480x480/png?text=VOI_006+S2', 'done', '动作提示', '第二段自然衔接。')
      ],
      [new MediaResourceItem('v-poster-7', 'poster-voi-006.png', 'https://placehold.co/720x1280/png?text=VOI_006+Poster', 'done')]
    ),
    new TrainingItem(
      12, '节奏控制 2', 'VOI_007', 'voice', 2, false, 70, 'enabled',
      '稳定语速训练。', '控制语速不过快，保持清晰。', '减少含混和吞音。',
      ['语速适中', '尾音清楚'], ['语速过快'],
      [new MediaResourceItem('v-cover-8', 'cover-voi-007.png', 'https://placehold.co/1280x720/png?text=VOI_007', 'done')],
      [new MediaResourceItem('v-video-8', 'voi-007.mp4', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/7375fc2d133c4ffdb11ed159fefd7a24%E4%BD%A0%E5%A5%BD.mp4', 'done')],
      [new MediaResourceItem('v-audio-8', 'voi-007.mp3', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/nihao.mp3', 'done')],
      [
        new MediaResourceItem('v-step-8-1', 'step-1.png', 'https://placehold.co/480x480/png?text=VOI_007+S1', 'done', '动作提示', '保持呼吸平稳。'),
        new MediaResourceItem('v-step-8-2', 'step-2.png', 'https://placehold.co/480x480/png?text=VOI_007+S2', 'done', '动作提示', '结尾避免漏气。')
      ],
      [new MediaResourceItem('v-poster-8', 'poster-voi-007.png', 'https://placehold.co/720x1280/png?text=VOI_007+Poster', 'done')]
    ),
    new TrainingItem(
      13, '清晰度强化 1', 'VOI_008', 'voice', 2, false, 80, 'enabled',
      '发音清晰度强化。', '聚焦起音与尾音的咬字。', '提高整体清晰度。',
      ['起音干净', '收尾到位'], ['尾音含混'],
      [new MediaResourceItem('v-cover-9', 'cover-voi-008.png', 'https://placehold.co/1280x720/png?text=VOI_008', 'done')],
      [new MediaResourceItem('v-video-9', 'voi-008.mp4', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/7375fc2d133c4ffdb11ed159fefd7a24%E4%BD%A0%E5%A5%BD.mp4', 'done')],
      [new MediaResourceItem('v-audio-9', 'voi-008.mp3', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/nihao.mp3', 'done')],
      [
        new MediaResourceItem('v-step-9-1', 'step-1.png', 'https://placehold.co/480x480/png?text=VOI_008+S1', 'done', '动作提示', '保持口型稳定。'),
        new MediaResourceItem('v-step-9-2', 'step-2.png', 'https://placehold.co/480x480/png?text=VOI_008+S2', 'done', '动作提示', '尾音快速收束。')
      ],
      [new MediaResourceItem('v-poster-9', 'poster-voi-008.png', 'https://placehold.co/720x1280/png?text=VOI_008+Poster', 'done')]
    ),
    new TrainingItem(
      14, '清晰度强化 2', 'VOI_009', 'voice', 2, false, 90, 'enabled',
      '连读清晰训练。', '连续跟读中保持每个音节清楚。', '提升稳定输出能力。',
      ['音节分明', '节奏平滑'], ['吞音'],
      [new MediaResourceItem('v-cover-10', 'cover-voi-009.png', 'https://placehold.co/1280x720/png?text=VOI_009', 'done')],
      [new MediaResourceItem('v-video-10', 'voi-009.mp4', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/7375fc2d133c4ffdb11ed159fefd7a24%E4%BD%A0%E5%A5%BD.mp4', 'done')],
      [new MediaResourceItem('v-audio-10', 'voi-009.mp3', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/nihao.mp3', 'done')],
      [
        new MediaResourceItem('v-step-10-1', 'step-1.png', 'https://placehold.co/480x480/png?text=VOI_009+S1', 'done', '动作提示', '连贯发音不抢拍。'),
        new MediaResourceItem('v-step-10-2', 'step-2.png', 'https://placehold.co/480x480/png?text=VOI_009+S2', 'done', '动作提示', '每个音节都发实。')
      ],
      [new MediaResourceItem('v-poster-10', 'poster-voi-009.png', 'https://placehold.co/720x1280/png?text=VOI_009+Poster', 'done')]
    ),
    new TrainingItem(
      15, '综合训练 1', 'VOI_010', 'voice', 3, true, 100, 'enabled',
      '综合能力训练。', '结合口型、节奏和清晰度进行实战。', '形成稳定发音模板。',
      ['稳定口型', '平稳节奏'], ['后段松散'],
      [new MediaResourceItem('v-cover-11', 'cover-voi-010.png', 'https://placehold.co/1280x720/png?text=VOI_010', 'done')],
      [new MediaResourceItem('v-video-11', 'voi-010.mp4', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/7375fc2d133c4ffdb11ed159fefd7a24%E4%BD%A0%E5%A5%BD.mp4', 'done')],
      [new MediaResourceItem('v-audio-11', 'voi-010.mp3', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/nihao.mp3', 'done')],
      [
        new MediaResourceItem('v-step-11-1', 'step-1.png', 'https://placehold.co/480x480/png?text=VOI_010+S1', 'done', '动作提示', '先稳住第一拍。'),
        new MediaResourceItem('v-step-11-2', 'step-2.png', 'https://placehold.co/480x480/png?text=VOI_010+S2', 'done', '动作提示', '中后段保持同速。')
      ],
      [new MediaResourceItem('v-poster-11', 'poster-voi-010.png', 'https://placehold.co/720x1280/png?text=VOI_010+Poster', 'done')]
    ),
    new TrainingItem(
      16, '综合训练 2', 'VOI_011', 'voice', 3, false, 110, 'enabled',
      '强度提升训练。', '增加重复次数，强化肌肉记忆。', '提升稳定度与抗干扰能力。',
      ['连续完成', '动作一致'], ['后半程掉速'],
      [new MediaResourceItem('v-cover-12', 'cover-voi-011.png', 'https://placehold.co/1280x720/png?text=VOI_011', 'done')],
      [new MediaResourceItem('v-video-12', 'voi-011.mp4', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/7375fc2d133c4ffdb11ed159fefd7a24%E4%BD%A0%E5%A5%BD.mp4', 'done')],
      [new MediaResourceItem('v-audio-12', 'voi-011.mp3', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/nihao.mp3', 'done')],
      [
        new MediaResourceItem('v-step-12-1', 'step-1.png', 'https://placehold.co/480x480/png?text=VOI_011+S1', 'done', '动作提示', '重复时保持一致。'),
        new MediaResourceItem('v-step-12-2', 'step-2.png', 'https://placehold.co/480x480/png?text=VOI_011+S2', 'done', '动作提示', '注意尾音不发散。')
      ],
      [new MediaResourceItem('v-poster-12', 'poster-voi-011.png', 'https://placehold.co/720x1280/png?text=VOI_011+Poster', 'done')]
    ),
    new TrainingItem(
      17, '综合训练 3', 'VOI_012', 'voice', 3, false, 120, 'enabled',
      '稳定输出训练。', '模拟真实交流场景进行跟读。', '保持自然、清晰、连贯。',
      ['自然跟读', '节奏一致'], ['节奏抖动'],
      [new MediaResourceItem('v-cover-13', 'cover-voi-012.png', 'https://placehold.co/1280x720/png?text=VOI_012', 'done')],
      [new MediaResourceItem('v-video-13', 'voi-012.mp4', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/7375fc2d133c4ffdb11ed159fefd7a24%E4%BD%A0%E5%A5%BD.mp4', 'done')],
      [new MediaResourceItem('v-audio-13', 'voi-012.mp3', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/nihao.mp3', 'done')],
      [
        new MediaResourceItem('v-step-13-1', 'step-1.png', 'https://placehold.co/480x480/png?text=VOI_012+S1', 'done', '动作提示', '起音自然不僵硬。'),
        new MediaResourceItem('v-step-13-2', 'step-2.png', 'https://placehold.co/480x480/png?text=VOI_012+S2', 'done', '动作提示', '尾音干净利落。')
      ],
      [new MediaResourceItem('v-poster-13', 'poster-voi-012.png', 'https://placehold.co/720x1280/png?text=VOI_012+Poster', 'done')]
    ),
    new TrainingItem(
      18, '综合训练 4', 'VOI_013', 'voice', 3, false, 130, 'enabled',
      '冲刺巩固训练。', '完成最终一轮整合演练。', '巩固全流程训练成果。',
      ['稳定完成', '保持清晰'], ['尾音拖长'],
      [new MediaResourceItem('v-cover-14', 'cover-voi-013.png', 'https://placehold.co/1280x720/png?text=VOI_013', 'done')],
      [new MediaResourceItem('v-video-14', 'voi-013.mp4', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/7375fc2d133c4ffdb11ed159fefd7a24%E4%BD%A0%E5%A5%BD.mp4', 'done')],
      [new MediaResourceItem('v-audio-14', 'voi-013.mp3', 'http://192.168.142.128:9001/hearbridge-bucket/20260316/nihao.mp3', 'done')],
      [
        new MediaResourceItem('v-step-14-1', 'step-1.png', 'https://placehold.co/480x480/png?text=VOI_013+S1', 'done', '动作提示', '先稳后快，保持节奏。'),
        new MediaResourceItem('v-step-14-2', 'step-2.png', 'https://placehold.co/480x480/png?text=VOI_013+S2', 'done', '动作提示', '收尾集中，不拖尾音。')
      ],
      [new MediaResourceItem('v-poster-14', 'poster-voi-013.png', 'https://placehold.co/720x1280/png?text=VOI_013+Poster', 'done')]
    )
  ]
}
