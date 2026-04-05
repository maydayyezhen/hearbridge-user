let globalToastTimer: number = -1

export type GlobalToastTone = 'success' | 'error' | 'info' | 'warning' | 'hint'

export function showGlobalToast(message: string, tone: GlobalToastTone = 'success', durationMs: number = 1800) {
  AppStorage.setOrCreate('globalToastText', message)
  AppStorage.setOrCreate('globalToastTone', tone)
  AppStorage.setOrCreate('globalToastVisible', true)
  if (globalToastTimer >= 0) {
    clearTimeout(globalToastTimer)
  }
  globalToastTimer = setTimeout(() => {
    AppStorage.setOrCreate('globalToastVisible', false)
    globalToastTimer = -1
  }, durationMs)
}

export function hideGlobalToast() {
  if (globalToastTimer >= 0) {
    clearTimeout(globalToastTimer)
    globalToastTimer = -1
  }
  AppStorage.setOrCreate('globalToastVisible', false)
}
