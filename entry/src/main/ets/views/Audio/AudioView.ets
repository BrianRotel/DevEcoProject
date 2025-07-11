import { auth } from '../../commons/components/Auth'
import { HcNavBar } from '../../commons/components/HcNavBar'
import { audioDB, InterviewAudioItem } from '../../commons/utils/InterviewAudioItem'
import { AudioItemComp } from './AudioItemComp'
import { AudioPlayer } from './AudioPlayer'
import { AudioRecordComp } from './AudioRecordComp'

@Extend(Text)
function actionButton(color: ResourceColor) {
  .width(80)
  .aspectRatio(1)
  .backgroundColor(color)
  .textAlign(TextAlign.Center)
  .fontColor($r('app.color.white'))
}

@CustomDialog
struct InputDialog {
  controller: CustomDialogController
  @Prop name: string = ''
  onSubmit: (name: string) => void = () => {
  }

  build() {
    Column({ space: 12 }) {
      Text('修改名字：')
        .height(40)
        .fontWeight(500)
      TextInput({ text: $$this.name })
      Row({ space: 120 }) {
        Text('取消')
          .fontWeight(500)
          .fontColor($r('app.color.common_gray_02'))
          .onClick(() => {
            this.controller.close()
          })
        Text('确认')
          .fontWeight(500)
          .fontColor($r('app.color.common_blue'))
          .onClick(() => {
            this.onSubmit(this.name)
          })
      }
      .height(40)
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .borderRadius(12)
    .width('80%')
    .backgroundColor($r('app.color.white'))
  }
}

@Component
export struct AudioView {
  @State list: InterviewAudioItem[] = [{} as InterviewAudioItem, {} as InterviewAudioItem]
  @State currentItem: InterviewAudioItem = {} as InterviewAudioItem
  @State isRecording: boolean = false
  @State isShow: boolean = false
  dialog = new CustomDialogController({
    builder: InputDialog({
      name: this.currentItem.name,
      onSubmit: async (name) => {
        const item = this.currentItem
        item.name = name
        await audioDB.update(item)
        await this.getList()
        this.dialog.close()
      }
    }),
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  async getList() {
    const user = auth.getUser()
    const rows = await audioDB.query(user.id)
    this.list = rows
  }

  async aboutToAppear() {
    await audioDB.initStore()
    await this.getList()
  }

  @Builder
  ListItemSwiperBuilder(item: InterviewAudioItem) {
    Row() {
      Text('编辑')
        .actionButton($r('app.color.common_blue'))
        .onClick(() => {
          this.currentItem = item
          this.dialog.open()
        })
      Text('删除')
        .actionButton('#FF0033')
        .actionButton('#FF0033')
        .onClick(async () => {
          await audioDB.delete(item.id!)
          this.getList()
        })
    }
    .height('100%')
  }

  @Builder
  PlayerBuilder() {
    Column() {
      AudioPlayer({ item: this.currentItem })
    }
  }

  build() {
    Column() {
      HcNavBar({ title: '面试录音', showRightIcon: false })
      Column() {
        List() {
          ForEach(this.list, (item: InterviewAudioItem) => {
            ListItem() {
              AudioItemComp({
                item: item
              })
                .onClick(() => {
                  this.currentItem = item
                  this.isShow = true
                })
            }
            .swipeAction({
              end: this.ListItemSwiperBuilder(item)
            })
          })
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .layoutWeight(1)

      AudioRecordComp({
        recording: this.isRecording,
        onRecordEnd: async (item: InterviewAudioItem) => {
          await audioDB.insert(item)
          this.getList()
        }
      })
    }
    .width('100%')
    .height('100%')
    .bindContentCover($$this.isShow, this.PlayerBuilder())
  }
}