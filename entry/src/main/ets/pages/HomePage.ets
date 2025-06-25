import { HomeCategory } from '../views/Home/HomeCategory';
import { HcSearchBox } from '../commons/components/HcSearchBox';
import { HcClockIn } from '../commons/components/HcClockIn';
import { QuestionItemComp } from '../commons/components/QuestionItemComp';
import { auth, UserStoreKey } from '../commons/components/Auth';
import { scanBarcode } from '@kit.ScanKit';
import { http } from '../commons/utils/Http';
import { QuestionDetail, User } from '../models';
import { promptAction, router } from '@kit.ArkUI';
import { tracking } from '../commons/utils/Tracking';
import { logger, requestClockIn } from '../commons/utils';

@Component
export struct HomePage {
  @StorageProp('topHeight') topHeight: number = 0
  @StorageProp(UserStoreKey) user: User = {} as User

  @Builder
  SwiperItemBuilder(src: ResourceStr) {
    Row() {
      Image(src)
        .width('100%')
        .aspectRatio(2.65)
        .objectFit(ImageFit.Fill)
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  async scanQuestionCode() {
    if (canIUse('SystemCapability.Multimedia.Scan.ScanBarcode')) {
      const result = await scanBarcode.startScanForResult(getContext(this))
      if (result.originalValue) {
        try {
          const item = await http.request<QuestionDetail>({ url: `question/${result.originalValue}` })
          router.pushUrl({
            url: 'pages/QuestionPage',
            params: {
              item,
              list: [item]
            }
          })
        } catch (e) {
          promptAction.showToast({ message: '没有找到试题' })
        }
      }
    }
  }

  aboutToAppear(): void {
    tracking.report(true)
  }

  build() {
    Column() {
      Row({ space: 16 }) {
        Image($r('app.media.ic_home_scan'))
          .width(24)
          .aspectRatio(1)
          .onClick(() => {
            auth.checkAuth(() => {
              this.scanQuestionCode();
            })
          });
        //Blank()
        HcSearchBox({ layoutWeightValue: 1 })
        HcClockIn({ clockInCount: this.user.clockinNumbers })
          .onClick(() => {
            requestClockIn()
          })
      }
      .padding({ left: 16, right: 16 })
      .height(64)
      .width('100%')

      Swiper() {
        ForEach([$r('app.media.banner_ai'), $r('app.media.banner_pj'), $r('app.media.banner_qa')],
          (item: ResourceStr) => {
            this.SwiperItemBuilder(item)
          })
      }
      .margin({ bottom: 16 })
      .autoPlay(true)
      .indicator(DotIndicator.dot()
        .bottom(4)
        .itemHeight(4)
        .selectedItemHeight(4)
        .selectedColor($r('app.color.white')))

      // 试题Tabs
      Column() {
        HomeCategory()
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor($r('app.color.white'))
    }
    .padding({ top: this.topHeight })
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.common_gray_bg'))

  }
}
