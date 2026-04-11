import { ApiResult } from '../../../api/common/Http'
import type {
  TrainSessionSummaryResponseSource,
  TrainSummaryDimensionSource,
  TrainSummaryHighlightItemSource,
  TrainSummarySuggestionSource,
  TrainSummaryTrendSource
} from '../api/TrainSessionApiService'
import { fetchTrainSessionSummary } from '../api/TrainSessionApiService'
import { normalizeTrainItemStatus, normalizeTrainingType } from '../../../utils/TrainingTypeUtil'
import {
  TrainSessionSummaryViewData,
  TrainSummaryDimensionViewData,
  TrainSummaryHighlightItemViewData,
  TrainSummarySuggestionViewData,
  TrainSummaryTrendViewData
} from '../model/TrainSessionSummaryViewData'

type SummaryFieldValue = string | number | boolean | Object | SummaryFieldValue[] | null | undefined

function readObjectByKeys(source: Object, keys: string[]): Object | undefined {
  for (let i = 0; i < keys.length; i += 1) {
    const value = Reflect.get(source, keys[i]) as SummaryFieldValue
    if (value !== null && value !== undefined && typeof value === 'object' && !Array.isArray(value)) {
      return value as Object
    }
  }
  return undefined
}

function resolveNestedPayload(payload: Object): Object {
  let resolved = payload
  const nestedKeys = ['data', 'summary', 'result']
  for (let depth = 0; depth < 3; depth += 1) {
    const nextPayload = readObjectByKeys(resolved, nestedKeys)
    if (!nextPayload) {
      break
    }
    resolved = nextPayload
  }
  return resolved
}

function parsePayloadFromRawBody(rawBody: string): Object | null {
  if (rawBody.length <= 0) {
    return null
  }
  try {
    const parsed = JSON.parse(rawBody) as SummaryFieldValue
    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
      return null
    }
    return resolveNestedPayload(parsed as Object)
  } catch (_error) {
    return null
  }
}

function resolveApiPayload<T extends Object>(result: ApiResult<T>): T | null {
  if (result.data && typeof result.data === 'object') {
    return resolveNestedPayload(result.data as Object) as T
  }
  if (result.httpCode === 200) {
    return parsePayloadFromRawBody(result.rawBody) as T | null
  }
  return null
}

export function createEmptyTrainSessionSummaryViewData(): TrainSessionSummaryViewData {
  return new TrainSessionSummaryViewData()
}

function mapDimension(source: TrainSummaryDimensionSource): TrainSummaryDimensionViewData {
  const mapped = new TrainSummaryDimensionViewData()
  mapped.key = String(source.key ?? '')
  mapped.label = String(source.label ?? '')
  mapped.score = Math.max(0, Math.min(100, Math.round(Number(source.score ?? 0))))
  mapped.description = String(source.description ?? '')
  return mapped
}

function mapTrend(source: TrainSummaryTrendSource | null | undefined): TrainSummaryTrendViewData {
  const mapped = new TrainSummaryTrendViewData()
  if (!source) {
    return mapped
  }
  mapped.title = String(source.title ?? '')
  mapped.description = String(source.description ?? '')
  const rawScores: Array<number | string> = source.scores ?? []
  const rawLabels: string[] = source.labels ?? []
  for (let index = 0; index < rawScores.length; index += 1) {
    mapped.scores.push(Math.max(0, Math.min(100, Math.round(Number(rawScores[index] ?? 0)))))
    mapped.labels.push(String(rawLabels[index] ?? `${index + 1}`))
  }
  return mapped
}

function mapSuggestion(source: TrainSummarySuggestionSource): TrainSummarySuggestionViewData {
  const mapped = new TrainSummarySuggestionViewData()
  mapped.title = String(source.title ?? '')
  mapped.description = String(source.description ?? '')
  return mapped
}

function mapHighlightItem(source: TrainSummaryHighlightItemSource): TrainSummaryHighlightItemViewData {
  const mapped = new TrainSummaryHighlightItemViewData()
  mapped.itemCode = String(source.itemCode ?? '')
  mapped.itemName = String(source.itemName ?? '')
  mapped.score = Math.max(0, Math.round(Number(source.score ?? 0)))
  mapped.status = normalizeTrainItemStatus(String(source.status ?? ''))
  return mapped
}

function mapSummaryPayload(source: TrainSessionSummaryResponseSource): TrainSessionSummaryViewData {
  const mapped = new TrainSessionSummaryViewData()
  mapped.sessionId = Math.max(0, Number(source.sessionId ?? 0))
  mapped.courseCode = String(source.courseCode ?? '')
  mapped.courseName = String(source.courseName ?? '')
  mapped.trainingType = normalizeTrainingType(String(source.trainingType ?? 'gesture'))
  mapped.summaryMode = String(source.summaryMode ?? '')
  mapped.textSource = String(source.textSource ?? '')
  mapped.completedCount = Math.max(0, Number(source.completedCount ?? 0))
  mapped.totalCount = Math.max(0, Number(source.totalCount ?? 0))
  mapped.completionPercent = Math.max(0, Math.min(100, Number(source.completionPercent ?? 0)))
  mapped.averageScore = Math.max(0, Math.round(Number(source.averageScore ?? 0)))
  mapped.bestScore = Math.max(0, Math.round(Number(source.bestScore ?? 0)))
  mapped.summaryTitle = String(source.summaryTitle ?? '')
  mapped.summaryDescription = String(source.summaryDescription ?? '')
  mapped.badges = (source.badges ?? []).map((item: string) => String(item ?? '')).filter((item: string) => item.length > 0)
  mapped.dimensions = (source.dimensions ?? []).map((item: TrainSummaryDimensionSource) => mapDimension(item))
    .filter((item: TrainSummaryDimensionViewData) => item.label.length > 0)
  mapped.trend = mapTrend(source.trend ?? null)
  mapped.suggestions = (source.suggestions ?? []).map((item: TrainSummarySuggestionSource) => mapSuggestion(item))
    .filter((item: TrainSummarySuggestionViewData) => item.title.length > 0 || item.description.length > 0)
  mapped.highlightItems = (source.highlightItems ?? []).map((item: TrainSummaryHighlightItemSource) => mapHighlightItem(item))
    .filter((item: TrainSummaryHighlightItemViewData) => item.itemCode.length > 0 || item.itemName.length > 0)
  mapped.completedAt = String(source.completedAt ?? '')
  return mapped
}

export async function loadTrainSessionSummary(sessionId: number): Promise<TrainSessionSummaryViewData> {
  if (sessionId <= 0) {
    return createEmptyTrainSessionSummaryViewData()
  }
  const result = await fetchTrainSessionSummary(sessionId)
  const payload = resolveApiPayload<TrainSessionSummaryResponseSource>(result)
  if (!result.ok || !payload) {
    throw new Error(result.message.length > 0 ? result.message : '加载训练总结失败')
  }
  return mapSummaryPayload(payload)
}
