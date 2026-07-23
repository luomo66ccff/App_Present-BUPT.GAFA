import { FragmentItem, FragmentVisibility } from '../model/FragmentModel';
import { TimeUtils } from '../utils/TimeUtils';

@Component
export struct FragmentCard {
  @Prop item: FragmentItem;
  onTap: (id: string) => void = () => {};

  private visibleTags(): string[] {
    const result: string[] = [];
    this.item.tags.forEach((value: string) => {
      const tag: string = value.trim();
      if (tag.length > 0 && !result.includes(tag)) {
        result.push(tag);
      }
    });
    return result.slice(0, 3);
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text(this.item.kind)
          .fontSize(13)
          .fontColor('#6F59D9')
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#F0ECFF')
          .borderRadius(14)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })

        Blank()

        Text(TimeUtils.relativeLabel(this.item.createdAt))
          .fontSize(12)
          .fontColor('#8C8996')
      }
      .width('100%')

      Text(this.item.content)
        .fontSize(17)
        .fontColor('#25232B')
        .lineHeight(25)
        .maxLines(4)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      Row({ space: 8 }) {
        ForEach(this.visibleTags(), (tag: string) => {
          Text(`#${tag}`)
            .fontSize(12)
            .fontColor('#716D7C')
        }, (tag: string) => tag)

        Blank()

        Text(this.item.visibility === FragmentVisibility.PRIVATE ? '仅自己' : '可接枝')
          .fontSize(12)
          .fontColor(this.item.visibility === FragmentVisibility.PRIVATE ? '#8C8996' : '#3B8C70')
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .border({ width: 1, color: '#ECEAF2' })
    .onClick(() => this.onTap(this.item.id))
  }
}
