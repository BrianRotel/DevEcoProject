import { QuestionItemComp } from '.'
import { PageData, QuestionItem, QuestionListParams, SortType } from '../../models'
import { http } from '../utils/Http'
import { promptAction } from '@kit.ArkUI'

@Component
export struct QuestionListComp {
  @State list: QuestionItem[] = []
  // 控制刷新的状态
  @State isRefreshing: boolean = false
  // 试题ID
  @Prop typeId: number
  @State page: number = 1
  @Prop @Watch('onChangeSort') sort: SortType = SortType.Default
  @Prop activeIndex: number
  @Prop index: number

  build() {
    Refresh({ refreshing: $$this.isRefreshing }) {
      List() {
        ForEach(this.list, (item: QuestionItem) => {
          ListItem() {
            QuestionItemComp({
              item: item
            })
          }
        })
        this.LoadMoreBuilder()
      }
      .divider({
        strokeWidth: 0.5,
        color: $r('app.color.common_gray_border'),
        startMargin: 16,
        endMargin: 16
      })
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .onReachEnd(() => {
        if (this.isLoading || this.isFinished || this.isRefreshing) {
          return
        }
        this.isLoading = true
        this.onLoad()
      })
    } // Refresh 绑定事件
    .onRefreshing(() => {
      this.onRefresh()
    })
  }

  async onRefresh() {
    this.page = 1
    const res = await this.getQuestionList()
    this.list = res.rows
    this.isRefreshing = false
    if (this.page >= res.pageTotal) {
      this.isFinished = true
    } else {
      this.isFinished = false
      this.page++
    }
    promptAction.showToast({ message: '更新成功' })
  }

  // 是否加载完成
  @State isFinished: boolean = false
  // 正在加载中...
  @State isLoading: boolean = false

  @Builder
  LoadMoreBuilder() {
    ListItem() {
      // 加载完成
      if (this.isFinished) {
        Row() {
          Text('没有更多了~')
            .fontSize(14)
            .fontColor($r('app.color.common_gray_03'))
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
      }
      // 没有加载完成且正在加载中
      else if (this.isLoading) {
        Row({ space: 4 }) {
          LoadingProgress()
            .width(20)
          Text('正在加载...')
            .fontSize(14)
            .fontColor($r('app.color.common_gray_03'))
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
      }
    }
    .height(80)
  }

  async onLoad() {
    const res = await this.getQuestionList()
    this.list.push(...res.rows)
    this.isLoading = false
    if (this.page >= res.pageTotal) {
      this.isFinished = true
    } else {
      this.page++
    }
  }

  getQuestionList(): Promise<PageData<QuestionItem>> {
    return http.request<PageData<QuestionItem>>({
      url: 'question/list',
      params: {
        type: this.typeId,
        questionBankType: 10,
        sort: this.sort,
        page: this.page,
        pageSize: 10
      } as QuestionListParams
    })
  }

  // 切换分类的时候，需要等待UI显示后去刷新
  onChangeSort() {
    if (this.activeIndex === this.index) {
      this.isRefreshing = true
    }
  }
}