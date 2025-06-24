import { auth } from '../components/Auth'
import { http } from './Http'
import { promptAction, router } from '@kit.ArkUI'

export * from './Logger'

export * from './FullScreen'

export * from './StatusBar'


interface ClockRes {
  clockinNumbers: number
}

export const requestClockIn = async () => {
  const user = auth.getUser()
  if (user.token) {
    if (user.clockinNumbers === 0) {
      const res = await http.request<ClockRes>({ url: 'clockin', method: 'post' })
      user.clockinNumbers = res.clockinNumbers
      auth.setUser(user)
      promptAction.showToast({ message: '打卡成功' })
    }
    router.pushUrl({ url: 'pages/ClockInPage' })
  } else {
    router.pushUrl({ url: 'pages/LoginPage' })
  }
}

export const calcPercentage = (done: number, total: number) => {
  return Math.round(done / total * 100) + '%'
}