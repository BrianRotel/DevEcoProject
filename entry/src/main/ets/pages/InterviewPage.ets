import { HcSkeleton, HcSkeletonItem } from "../commons/components/HcSkeleton"

@Component
export struct InterviewPage {
  build() {

    HcSkeleton() {
      Column({ space: 16 }) {
        HcSkeletonItem({ widthValue: 100 })
        HcSkeletonItem({ widthValue: '50%' })
        HcSkeletonItem()
      }
      .padding(16)
    }
  }
}