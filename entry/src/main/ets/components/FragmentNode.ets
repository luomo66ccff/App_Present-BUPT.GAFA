import { FragmentTheme } from '../theme/FragmentTheme';

@Component
export struct FragmentNode {
  @Prop title: string = '';
  @Prop active: boolean = false;

  build() {
    Column({ space: 6 }) {
      Circle()
        .width(this.active ? 54 : 42)
        .height(this.active ? 54 : 42)
        .fill(this.active ? FragmentTheme.primary : '#DCD8EA')
      Text(this.title)
        .fontSize(12)
        .fontColor(FragmentTheme.text)
        .maxLines(2)
    }
  }
}
