import { FragmentItem } from '../model/FragmentModel';
import { FragmentTheme } from '../theme/FragmentTheme';

@Component
export struct SeedCard {
  @Prop item: FragmentItem;

  build() {
    Column({ space: 10 }) {
      Text('✦')
        .fontSize(18)
        .fontColor(FragmentTheme.primary)

      Text(this.item.content)
        .fontSize(17)
        .fontColor(FragmentTheme.text)
        .lineHeight(26)

      Row({ space: 8 }) {
        ForEach(this.item.tags, (tag: string) => {
          Text(`#${tag}`)
            .fontSize(12)
            .fontColor(FragmentTheme.secondary)
        }, (tag: string) => tag)
      }
    }
    .padding(20)
    .width('100%')
    .backgroundColor(FragmentTheme.card)
    .borderRadius(28)
    .shadow({ radius: 12, color: '#12000000', offsetX: 0, offsetY: 4 })
  }
}
