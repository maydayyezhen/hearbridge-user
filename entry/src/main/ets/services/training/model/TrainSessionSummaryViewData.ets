import { TrainItemStatus, TrainingType } from '../../../domain/static/train/TrainingRuntimeTypes'

export class TrainSummaryDimensionViewData {
  key: string = ''
  label: string = ''
  score: number = 0
  description: string = ''
}

export class TrainSummaryTrendViewData {
  title: string = ''
  scores: number[] = []
  labels: string[] = []
  description: string = ''
}

export class TrainSummarySuggestionViewData {
  title: string = ''
  description: string = ''
}

export class TrainSummaryHighlightItemViewData {
  itemCode: string = ''
  itemName: string = ''
  score: number = 0
  status: TrainItemStatus = ''
}

export class TrainSessionSummaryViewData {
  sessionId: number = 0
  courseCode: string = ''
  courseName: string = ''
  trainingType: TrainingType = 'gesture'
  summaryMode: string = ''
  textSource: string = ''
  completedCount: number = 0
  totalCount: number = 0
  completionPercent: number = 0
  averageScore: number = 0
  bestScore: number = 0
  summaryTitle: string = ''
  summaryDescription: string = ''
  badges: string[] = []
  dimensions: TrainSummaryDimensionViewData[] = []
  trend: TrainSummaryTrendViewData = new TrainSummaryTrendViewData()
  suggestions: TrainSummarySuggestionViewData[] = []
  highlightItems: TrainSummaryHighlightItemViewData[] = []
  completedAt: string = ''
}
