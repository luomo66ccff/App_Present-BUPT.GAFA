enum AppPage {
  BOX = 0,
  COLLECTION = 1,
  COMMUNITY = 2
}

class FragmentItem {
  id: string = ''
  tag: string = ''
  text: string = ''
  tone: string = ''
  remind: string = ''
  shared: boolean = false
  createdAt: string = ''

  constructor(id: string, tag: string, text: string, tone: string, remind: string, shared: boolean, createdAt: string) {
    this.id = id
    this.tag = tag
    this.text = text
    this.tone = tone
    this.remind = remind
    this.shared = shared
    this.createdAt = createdAt
  }
}

class GraphNode {
  key: string = ''
  label: string = ''
  name: string = ''
  tone: string = ''
  x: number = 0
  y: number = 0
  fragmentIndex: number = -1

  constructor(key: string, label: string, name: string, tone: string, x: number, y: number, fragmentIndex: number) {
    this.key = key
    this.label = label
    this.name = name
    this.tone = tone
    this.x = x
    this.y = y
    this.fragmentIndex = fragmentIndex
  }
}

class GraphEdge {
  key: string = ''
  fromKey: string = ''
  toKey: string = ''
  color: string = ''

  constructor(key: string, fromKey: string, toKey: string, color: string) {
    this.key = key
    this.fromKey = fromKey
    this.toKey = toKey
    this.color = color
  }
}

class NodePosition {
  x: number = 0
  y: number = 0
  w: number = 0
  h: number = 0

  constructor(x: number, y: number, w: number, h: number) {
    this.x = x
    this.y = y
    this.w = w
    this.h = h
  }
}

class ChildLineInfo {
  cx: number = 0
  top: number = 0

  constructor(cx: number, top: number) {
    this.cx = cx
    this.top = top
  }
}

class CommunityNode {
  key: string = ''
  parent: string = ''
  title: string = ''
  tag: string = ''
  author: string = ''
  match: string = ''
  text: string = ''
  tone: string = ''
  x: number = 0
  y: number = 0
  w: number = 0
  h: number = 0

  constructor(
    key: string,
    parent: string,
    title: string,
    tag: string,
    author: string,
    match: string,
    text: string,
    tone: string,
    x: number,
    y: number,
    w: number,
    h: number
  ) {
    this.key = key
    this.parent = parent
    this.title = title
    this.tag = tag
    this.author = author
    this.match = match
    this.text = text
    this.tone = tone
    this.x = x
    this.y = y
    this.w = w
    this.h = h
  }
}

@Entry
@Component
struct Index {
  @State currentPage: AppPage = AppPage.BOX
  @State graphMode: boolean = false
  @State showInputSheet: boolean = false
  @State activeIndex: number = 2
  @State activeCommunityKey: string = 'root'
  @State expandedCommunityKeys: string[] = ['root']
  @State draftContent: string = ''
  @State draftTag: string = ''
  @State draftRemind: string = '通勤'
  @State shareEnabled: boolean = true
  @State toastText: string = ''
  @State showToast: boolean = false
  @State activeGraphNodeKey: string = 'n3'

  private treeCanvasSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private treeCanvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.treeCanvasSettings)
  @State treeNodePositions: Map<string, NodePosition> = new Map()
  @State treeContainerGlobalX: number = 0
  @State treeContainerGlobalY: number = 0
  @State treeRedrawTrigger: number = 0
  @State boxFloatY: number = 0

  private graphCanvasSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private graphCanvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.graphCanvasSettings)
  private graphNodeRadius: number = 10
  private graphSourceMinX: number = 60
  private graphSourceMaxX: number = 330
  private graphSourceMinY: number = 80
  private graphSourceMaxY: number = 450

  @State fragments: FragmentItem[] = [
    new FragmentItem('01', '通勤观察', '人在很累的时候，不是不想社交，而是不想解释自己。', 'memory', '通勤', true, '07.18'),
    new FragmentItem('02', '复盘经验', '临时安排让我焦虑，可能是因为我需要提前准备情绪。', 'self', '睡前', false, '07.19'),
    new FragmentItem('03', '社交边界', '我不是讨厌社交，我是讨厌临时社交。', 'self', '周末', true, '07.21'),
    new FragmentItem('04', '灵感脑洞', '可以把人的社交状态想成电量，而不是性格。', 'idea', '睡前', true, '07.21'),
    new FragmentItem('05', '行动方向', '以后可以提前告诉朋友：我需要一点计划感。', 'idea', '通勤', false, '07.22'),
    new FragmentItem('06', '情绪瞬间', '不回复消息不是冷淡，有时只是系统正在降温。', 'memory', '周末', true, '07.22')
  ]

  private graphNodes: GraphNode[] = [
    new GraphNode('n1', '01', '通勤观察', 'memory', 74, 132, 0),
    new GraphNode('n2', '02', '复盘经验', 'self', 178, 92, 1),
    new GraphNode('n3', '03', '社交边界', 'self', 184, 294, 2),
    new GraphNode('n4', '04', '灵感脑洞', 'idea', 284, 152, 3),
    new GraphNode('n5', '05', '行动方向', 'idea', 288, 358, 4),
    new GraphNode('n6', '06', '情绪瞬间', 'memory', 116, 432, 5),
    new GraphNode('m1', '', '', 'micro', 96, 256, -1),
    new GraphNode('m2', '', '', 'micro', 134, 306, -1),
    new GraphNode('m3', '', '', 'micro', 220, 232, -1),
    new GraphNode('m4', '', '', 'micro', 198, 402, -1),
    new GraphNode('m5', '', '', 'micro', 318, 264, -1)
  ]

  private graphEdges: GraphEdge[] = [
    new GraphEdge('e1', 'n1', 'n2', 'rgba(113, 151, 160, 0.30)'),
    new GraphEdge('e2', 'n1', 'n3', 'rgba(113, 151, 160, 0.18)'),
    new GraphEdge('e3', 'n2', 'n3', 'rgba(113, 151, 160, 0.20)'),
    new GraphEdge('e4', 'n3', 'n4', 'rgba(176, 125, 145, 0.20)'),
    new GraphEdge('e5', 'n3', 'n5', 'rgba(176, 125, 145, 0.24)'),
    new GraphEdge('e6', 'n3', 'n6', 'rgba(179, 159, 91, 0.28)'),
    new GraphEdge('e7', 'n4', 'n5', 'rgba(192, 194, 188, 0.30)'),
    new GraphEdge('e8', 'n1', 'm2', 'rgba(192, 194, 188, 0.24)'),
    new GraphEdge('e9', 'm3', 'n4', 'rgba(192, 194, 188, 0.24)')
  ]

  private communityNodes: CommunityNode[] = [
    new CommunityNode('root', '', '当前碎片', '当前碎片', '我的 Box', '延申起点', '', 'root', 54, 18, 208, 66),
    new CommunityNode('similar', 'root', '相似经验', '相似经验', '匿名共享', 'AI 匹配：语义相近', '我发现自己不是抗拒见面，而是抗拒没有边界感的临时邀约。', 'slate', 0, 128, 98, 66),
    new CommunityNode('opposite', 'root', '相反经验', '相反经验', 'Luna', 'AI 匹配：相反视角', '有时突然被叫出去反而让我重新启动，计划太满才会让我失去弹性。', 'blue', 109, 128, 98, 66),
    new CommunityNode('action', 'root', '行动方向', '可借鉴做法', '匿名共享', 'AI 匹配：行动线索', '我会给朋友一个默认回复模板：今天电量低，但我不是不在乎。', 'green', 218, 128, 98, 66),
    new CommunityNode('metaphor', 'opposite', '延申比喻', '延申比喻', 'River', '来自相反经验的分叉', '社交电量也许不是电池，更像天气：它会变，但不需要被评判。', 'rose', 102, 236, 112, 66),
    new CommunityNode('city', 'similar', '城市观察', '城市观察', 'M.', '来自相似经验的分叉', '早高峰里很多人看起来冷漠，其实只是把情绪调到省电模式。', 'slate', 0, 340, 108, 66),
    new CommunityNode('reply', 'action', '关系提醒', '关系提醒', 'K', '来自行动做法的分叉', '边界不是拒绝关系，而是让关系不要总靠临时消耗来证明。', 'blue', 208, 340, 108, 66),
    new CommunityNode('silence', 'metaphor', '轻复盘', '轻复盘', '匿名共享', '继续延申：情绪恢复', '不回复消息的那段空白，可能是大脑在把外界声音慢慢降下来。', 'rose', 104, 430, 108, 66)
  ]

  aboutToAppear(): void {
    setInterval(() => {
      this.boxFloatY = this.boxFloatY === 0 ? -10 : 0
    }, 2200)
  }

  build() {
    Stack() {
      this.AppBackground()

      if (this.currentPage === AppPage.BOX) {
        this.BoxPage()
      } else if (this.currentPage === AppPage.COLLECTION) {
        this.CollectionPage()
      } else {
        this.CommunityPage()
      }

      this.PageDots()

      if (this.showToast) {
        this.Toast()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f7f7f3')
    .blur(this.showInputSheet ? 3 : 0)
    .bindSheet($$this.showInputSheet, this.InputSheet(), {
      height: 560,
      showClose: false,
      dragBar: false,
      backgroundColor: 'rgba(0, 0, 0, 0.25)'
    })
    .animation({ duration: 260, curve: Curve.EaseOut })
    .gesture(
      PanGesture({ direction: PanDirection.All, distance: 18 })
        .onActionEnd((event: GestureEvent) => {
          this.handlePan(event.offsetX, event.offsetY)
        })
    )
  }

  private currentFragment(): FragmentItem {
    if (this.fragments.length === 0) {
      return new FragmentItem('00', '空 Box', '还没有碎片。', 'self', '通勤', false, '')
    }
    return this.fragments[this.normalizedFragmentIndex(this.activeIndex)]
  }

  private normalizedFragmentIndex(index: number): number {
    if (this.fragments.length === 0) {
      return 0
    }
    if (index < 0) {
      return 0
    }
    if (index >= this.fragments.length) {
      return this.fragments.length - 1
    }
    return index
  }

  private fragmentAtOffset(delta: number): FragmentItem {
    if (this.fragments.length === 0) {
      return new FragmentItem('00', '空 Box', '还没有碎片。', 'self', '通勤', false, '')
    }
    return this.fragments[(this.activeIndex + delta + this.fragments.length) % this.fragments.length]
  }

  // 顶层手势：横向切换三页；在个人碎片页纵向切换碎片。
  private handlePan(offsetX: number, offsetY: number): void {
    if (this.showInputSheet) {
      return
    }
    if (Math.abs(offsetX) > Math.abs(offsetY) && Math.abs(offsetX) > 56) {
      if (offsetX < 0) {
        this.goNextPage()
      } else {
        this.goPreviousPage()
      }
      return
    }
  }

  private goNextPage(): void {
    if (this.currentPage === AppPage.BOX) {
      this.currentPage = AppPage.COLLECTION
      return
    }
    if (this.currentPage === AppPage.COLLECTION) {
      this.graphMode = false
      this.currentPage = AppPage.COMMUNITY
    }
  }

  private goPreviousPage(): void {
    if (this.currentPage === AppPage.COMMUNITY) {
      this.currentPage = AppPage.COLLECTION
      return
    }
    if (this.currentPage === AppPage.COLLECTION) {
      this.graphMode = false
      this.currentPage = AppPage.BOX
    }
  }

  private moveFragment(delta: number): void {
    let count: number = this.fragments.length
    if (count === 0) {
      return
    }
    this.activeIndex = (this.activeIndex + delta + count) % count
    this.activeCommunityKey = 'root'
  }

  private archiveFragment(): void {
    let content: string = this.draftContent.trim()
    let tag: string = this.draftTag.trim()
    if (content.length === 0) {
      content = '一个还没确定价值的碎片已放入 Box，等待未来重新出现。'
    }
    if (tag.length === 0) {
      tag = '未命名碎片'
    }
    let nextId: string = this.nextFragmentId()
    let item: FragmentItem = new FragmentItem(nextId, tag, content, 'self', this.draftRemind, this.shareEnabled, '今天')
    this.fragments = this.fragments.concat([item])
    this.activeIndex = this.fragments.length - 1
    this.draftContent = ''
    this.draftTag = ''
    this.showInputSheet = false
    this.showNotice(this.shareEnabled ? '已放入 Box · 匿名共享' : '已放入 Box · 仅自己可见')
  }

  private nextFragmentId(): string {
    let value: number = this.fragments.length + 1
    return value < 10 ? '0' + value.toString() : value.toString()
  }

  private showNotice(message: string): void {
    this.toastText = message
    this.showToast = true
    setTimeout(() => {
      this.showToast = false
    }, 1500)
  }

  private getToneColor(tone: string): string {
    if (tone === 'idea') {
      return '#b695a5'
    }
    if (tone === 'memory') {
      return '#8aa9ae'
    }
    if (tone === 'green') {
      return '#8fa783'
    }
    if (tone === 'blue') {
      return '#91a4b5'
    }
    if (tone === 'rose') {
      return '#b08a9a'
    }
    if (tone === 'slate') {
      return '#a5a8a5'
    }
    if (tone === 'micro') {
      return '#a9aca8'
    }
    return '#91a883'
  }

  private isExpanded(key: string): boolean {
    return this.expandedCommunityKeys.indexOf(key) >= 0
  }

  private childrenOf(key: string): CommunityNode[] {
    return this.communityNodes.filter((item: CommunityNode) => item.parent === key)
  }

  private getCommunityNode(key: string): CommunityNode {
    for (let i: number = 0; i < this.communityNodes.length; i++) {
      if (this.communityNodes[i].key === key) {
        return this.communityNodes[i]
      }
    }
    return this.communityNodes[0]
  }

  private visibleCommunityNodes(): CommunityNode[] {
    let visible: CommunityNode[] = []
    this.collectVisible(this.communityNodes[0], visible)
    return visible
  }

  private collectVisible(node: CommunityNode, visible: CommunityNode[]): void {
    visible.push(node)
    if (!this.isExpanded(node.key)) {
      return
    }
    this.childrenOf(node.key).forEach((child: CommunityNode) => {
      this.collectVisible(child, visible)
    })
  }

  private currentSharedNode(): CommunityNode {
    if (this.activeCommunityKey === 'root') {
      let current: FragmentItem = this.currentFragment()
      return new CommunityNode('root', '', '当前碎片', current.tag, '我的 Box', '延申起点', current.text, 'root', 0, 0, 0, 0)
    }
    return this.getCommunityNode(this.activeCommunityKey)
  }

  private selectCommunityNode(key: string): void {
    this.activeCommunityKey = key
    if (this.childrenOf(key).length > 0 && !this.isExpanded(key)) {
      this.expandedCommunityKeys = this.expandedCommunityKeys.concat([key])
    }
  }

  private saveSharedFragment(): void {
    let current: CommunityNode = this.currentSharedNode()
    if (current.key === 'root') {
      this.showNotice('这是当前碎片')
      return
    }
    let nextId: string = this.nextFragmentId()
    let item: FragmentItem = new FragmentItem(nextId, '共享 · ' + current.tag, current.text, 'memory', '周末', false, '今天')
    this.fragments = this.fragments.concat([item])
    this.activeIndex = this.fragments.length - 1
    this.currentPage = AppPage.COLLECTION
    this.graphMode = false
    this.showNotice('已收进 Box')
  }

  private branchSharedFragment(): void {
    let current: CommunityNode = this.currentSharedNode()
    if (this.childrenOf(current.key).length > 0) {
      this.selectCommunityNode(current.key)
      this.showNotice('已展开下一层')
      return
    }
    this.showNotice('已到达这一支的末端')
  }

  private treeEdgeLength(x1: number, y1: number, x2: number, y2: number): number {
    let dx: number = x2 - x1
    let dy: number = y2 - y1
    return Math.sqrt(dx * dx + dy * dy)
  }

  private treeEdgeAngle(x1: number, y1: number, x2: number, y2: number, angleOffset: number): number {
    return Math.atan2(y2 - y1, x2 - x1) * 57.2958 + angleOffset
  }

  private graphX(x: number): number {
    return 28 + (x - 60) * 0.82
  }

  private graphY(y: number): number {
    return 34 + (y - 80) * 0.96
  }

  private graphEdgeAngle(from: GraphNode, to: GraphNode): number {
    return Math.atan2(this.graphY(to.y) - this.graphY(from.y), this.graphX(to.x) - this.graphX(from.x)) * 57.2958
  }

  private graphEdgeLength(from: GraphNode, to: GraphNode): number {
    let dx: number = this.graphX(to.x) - this.graphX(from.x)
    let dy: number = this.graphY(to.y) - this.graphY(from.y)
    return Math.sqrt(dx * dx + dy * dy)
  }

  private graphNodeByKey(key: string): GraphNode {
    for (let i: number = 0; i < this.graphNodes.length; i++) {
      if (this.graphNodes[i].key === key) {
        return this.graphNodes[i]
      }
    }
    return this.graphNodes[0]
  }

  private isGraphEdgeActive(edge: GraphEdge): boolean {
    return edge.fromKey === this.activeGraphNodeKey || edge.toKey === this.activeGraphNodeKey
  }

  private isGraphNodeRelated(node: GraphNode): boolean {
    if (node.key === this.activeGraphNodeKey) {
      return true
    }
    for (let i: number = 0; i < this.graphEdges.length; i++) {
      let edge: GraphEdge = this.graphEdges[i]
      if ((edge.fromKey === this.activeGraphNodeKey && edge.toKey === node.key) ||
        (edge.toKey === this.activeGraphNodeKey && edge.fromKey === node.key)) {
        return true
      }
    }
    return false
  }

  private graphNodeKeyword(node: GraphNode): string {
    if (node.name.length > 0) {
      return node.name
    }
    return '关联点'
  }

  private graphControlX(edge: GraphEdge): number {
    let from: GraphNode = this.graphNodeByKey(edge.fromKey)
    let to: GraphNode = this.graphNodeByKey(edge.toKey)
    let dx: number = this.graphX(to.x) - this.graphX(from.x)
    let dy: number = this.graphY(to.y) - this.graphY(from.y)
    return (this.graphX(from.x) + this.graphX(to.x)) / 2 - dy * 0.18
  }

  private graphControlY(edge: GraphEdge): number {
    let from: GraphNode = this.graphNodeByKey(edge.fromKey)
    let to: GraphNode = this.graphNodeByKey(edge.toKey)
    let dx: number = this.graphX(to.x) - this.graphX(from.x)
    return (this.graphY(from.y) + this.graphY(to.y)) / 2 + dx * 0.18
  }

  private graphCurveX(edge: GraphEdge, t: number): number {
    let from: GraphNode = this.graphNodeByKey(edge.fromKey)
    let to: GraphNode = this.graphNodeByKey(edge.toKey)
    let oneMinus: number = 1 - t
    return oneMinus * oneMinus * this.graphX(from.x) + 2 * oneMinus * t * this.graphControlX(edge) + t * t * this.graphX(to.x)
  }

  private graphCurveY(edge: GraphEdge, t: number): number {
    let from: GraphNode = this.graphNodeByKey(edge.fromKey)
    let to: GraphNode = this.graphNodeByKey(edge.toKey)
    let oneMinus: number = 1 - t
    return oneMinus * oneMinus * this.graphY(from.y) + 2 * oneMinus * t * this.graphControlY(edge) + t * t * this.graphY(to.y)
  }

  private graphCurveSegmentLength(edge: GraphEdge, startT: number, endT: number): number {
    let dx: number = this.graphCurveX(edge, endT) - this.graphCurveX(edge, startT)
    let dy: number = this.graphCurveY(edge, endT) - this.graphCurveY(edge, startT)
    return Math.sqrt(dx * dx + dy * dy)
  }

  private graphCurveSegmentAngle(edge: GraphEdge, startT: number, endT: number): number {
    return Math.atan2(this.graphCurveY(edge, endT) - this.graphCurveY(edge, startT), this.graphCurveX(edge, endT) - this.graphCurveX(edge, startT)) * 57.2958
  }

  private graphCanvasX(node: GraphNode, width: number): number {
    let usableWidth: number = width - 56
    return 28 + (node.x - this.graphSourceMinX) / (this.graphSourceMaxX - this.graphSourceMinX) * usableWidth
  }

  private graphCanvasY(node: GraphNode, height: number): number {
    let usableHeight: number = height - 74
    return 34 + (node.y - this.graphSourceMinY) / (this.graphSourceMaxY - this.graphSourceMinY) * usableHeight
  }

  private drawGraphCanvas(): void {
    let width: number = this.graphCanvasContext.width
    let height: number = this.graphCanvasContext.height
    if (width <= 0 || height <= 0) {
      return
    }

    this.graphCanvasContext.clearRect(0, 0, width, height)
    this.drawGraphCanvasEdges(width, height)
    this.drawGraphCanvasNodes(width, height)
    this.drawGraphCanvasLabels(width, height)
  }

  private drawGraphCanvasEdges(width: number, height: number): void {
    for (let i: number = 0; i < this.graphEdges.length; i++) {
      let edge: GraphEdge = this.graphEdges[i]
      let from: GraphNode = this.graphNodeByKey(edge.fromKey)
      let to: GraphNode = this.graphNodeByKey(edge.toKey)
      let active: boolean = this.isGraphEdgeActive(edge)
      this.graphCanvasContext.beginPath()
      this.graphCanvasContext.moveTo(this.graphCanvasX(from, width), this.graphCanvasY(from, height))
      this.graphCanvasContext.lineTo(this.graphCanvasX(to, width), this.graphCanvasY(to, height))
      this.graphCanvasContext.strokeStyle = active ? 'rgba(74, 82, 76, 0.86)' : 'rgba(145, 148, 142, 0.22)'
      this.graphCanvasContext.lineWidth = active ? 3.6 : 1
      this.graphCanvasContext.stroke()
    }
  }

  private drawGraphCanvasNodes(width: number, height: number): void {
    for (let i: number = 0; i < this.graphNodes.length; i++) {
      let node: GraphNode = this.graphNodes[i]
      let related: boolean = this.isGraphNodeRelated(node)
      this.graphCanvasContext.beginPath()
      this.graphCanvasContext.arc(this.graphCanvasX(node, width), this.graphCanvasY(node, height), this.graphNodeRadius, 0, Math.PI * 2)
      this.graphCanvasContext.fillStyle = node.key === this.activeGraphNodeKey ? '#3f4440' : this.getToneColor(node.tone)
      this.graphCanvasContext.globalAlpha = related ? 0.96 : 0.34
      this.graphCanvasContext.fill()
      this.graphCanvasContext.globalAlpha = 1
      if (related) {
        this.graphCanvasContext.beginPath()
        this.graphCanvasContext.arc(this.graphCanvasX(node, width), this.graphCanvasY(node, height), this.graphNodeRadius, 0, Math.PI * 2)
        this.graphCanvasContext.strokeStyle = node.key === this.activeGraphNodeKey ? 'rgba(49, 53, 50, 0.72)' : 'rgba(90, 98, 91, 0.42)'
        this.graphCanvasContext.lineWidth = node.key === this.activeGraphNodeKey ? 2.4 : 1.4
        this.graphCanvasContext.stroke()
      }
    }
  }

  private drawGraphCanvasLabels(width: number, height: number): void {
    this.graphCanvasContext.font = '12px sans-serif'
    this.graphCanvasContext.textAlign = 'center'
    this.graphCanvasContext.textBaseline = 'top'
    for (let i: number = 0; i < this.graphNodes.length; i++) {
      let node: GraphNode = this.graphNodes[i]
      this.graphCanvasContext.fillStyle = this.isGraphNodeRelated(node) ? '#565a55' : '#a3a69f'
      this.graphCanvasContext.fillText(this.graphNodeKeyword(node), this.graphCanvasX(node, width), this.graphCanvasY(node, height) + this.graphNodeRadius + 8, 76)
    }
  }

  private handleGraphCanvasTouch(event: TouchEvent): void {
    if (event.type !== TouchType.Down || event.touches.length === 0) {
      return
    }
    let touchX: number = event.touches[0].x
    let touchY: number = event.touches[0].y
    let width: number = this.graphCanvasContext.width
    let height: number = this.graphCanvasContext.height
    for (let i: number = 0; i < this.graphNodes.length; i++) {
      let node: GraphNode = this.graphNodes[i]
      let dx: number = touchX - this.graphCanvasX(node, width)
      let dy: number = touchY - this.graphCanvasY(node, height)
      if (Math.sqrt(dx * dx + dy * dy) <= this.graphNodeRadius + 8) {
        this.selectGraphNode(node)
        return
      }
    }
  }

  private selectGraphNode(node: GraphNode): void {
    this.activeGraphNodeKey = node.key
    if (node.fragmentIndex >= 0 && node.fragmentIndex < this.fragments.length) {
      this.activeIndex = node.fragmentIndex
    }
    this.drawGraphCanvas()
  }

  @Builder
  AppBackground() {
    Stack() {
      // 纸面颗粒与极淡轨道，承担统一视觉质感，不参与交互。
      Circle()
        .width(420)
        .height(420)
        .fill('rgba(255, 255, 255, 0.42)')
        .stroke('rgba(213, 214, 208, 0.42)')
        .strokeWidth(1)
        .position({ x: -238, y: 250 })

      Circle()
        .width(250)
        .height(250)
        .fill('rgba(151, 161, 156, 0.08)')
        .position({ x: 210, y: 382 })

      Circle()
        .width(230)
        .height(230)
        .fill('rgba(255, 255, 255, 0.62)')
        .position({ x: 88, y: 130 })

      Circle().width(4).height(4).fill('rgba(48, 50, 49, 0.12)').position({ x: 70, y: 88 })
      Circle().width(3).height(3).fill('rgba(48, 50, 49, 0.08)').position({ x: 245, y: 118 })
      Circle().width(5).height(5).fill('rgba(48, 50, 49, 0.10)').position({ x: 112, y: 308 })
      Circle().width(3).height(3).fill('rgba(48, 50, 49, 0.08)').position({ x: 306, y: 510 })
      Circle().width(5).height(5).fill('rgba(48, 50, 49, 0.09)').position({ x: 52, y: 648 })
      Circle().width(3).height(3).fill('rgba(48, 50, 49, 0.07)').position({ x: 268, y: 692 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  BrandBadge() {
    Text('BOX')
      .fontSize(28)
      .fontWeight(FontWeight.Bold)
      .fontColor('#ffffff')
      .letterSpacing(4)
      .height(42)
      .lineHeight(42)
      .padding({ left: 8, right: 8 })
      .backgroundColor('#5d61d5')
  }

  @Builder
  BoxPage() {
    Stack() {
      Stack() {
        this.BrandBadge()
      }
      .width(108)
      .height(42)
        .position({ x: 8, y: 18 })

      Column() {
        this.BoxArt()

        Text('放入碎片')
          .fontSize(23)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2f3031')
          .letterSpacing(6)
          .margin({ top: 30 })

        Text('Drop a fragment')
          .fontSize(12)
          .fontColor('#9a9d97')
          .letterSpacing(0.6)
          .margin({ top: 10 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        this.showInputSheet = true
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 26, right: 26, top: 42, bottom: 88 })
  }

  @Builder
  BoxArt() {
    Stack({ alignContent: Alignment.Center }) {
      // Floor shadow: flat ellipse with blur, grounded look
      Ellipse()
        .width(140)
        .height(24)
        .fill('rgba(32, 33, 34, 0.15)')
        .blur(6)
        .translate({ y: 82 })

      // Mystery box image with continuous floating animation
      Image($r('app.media.app_icon'))
        .width(200)
        .height(200)
        .objectFit(ImageFit.Contain)
        .translate({ y: this.boxFloatY })
        .animation({
          duration: 2200,
          curve: Curve.EaseInOut,
          iterations: -1,
          playMode: PlayMode.Alternate
        })
    }
    .width(300)
    .height(260)
  }

  @Builder
  CollectionPage() {
    Stack() {
      Stack() {
        this.WaterfallBackground()
      }
      .width('100%')
      .height('100%')
        .zIndex(0)

      if (!this.graphMode) {
        Stack() {
          this.WaterfallOrbitLines()
        }
        .width('100%')
        .height('100%')
          .zIndex(1)
      }

      if (this.graphMode) {
        Stack() {
          this.PersonalGraph()
        }
        .width('100%')
        .height('100%')
          .zIndex(2)
      } else {
        Stack() {
          this.FragmentWaterfallPage()
        }
        .width('100%')
        .height('100%')
          .zIndex(2)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  WaterfallBackground() {
    Stack() {
      Circle()
        .width(430)
        .height(430)
        .fill('rgba(255, 255, 255, 0.18)')
        .stroke('rgba(204, 206, 200, 0.42)')
        .strokeWidth(1)
        .position({ x: -282, y: 176 })

      Circle()
        .width(226)
        .height(226)
        .fill('rgba(255, 255, 255, 0.42)')
        .position({ x: 136, y: 166 })

      Circle()
        .width(220)
        .height(220)
        .fill('rgba(151, 161, 156, 0.07)')
        .position({ x: 238, y: 520 })

      Circle().width(5).height(5).fill('rgba(46, 48, 47, 0.12)').position({ x: 92, y: 152 })
      Circle().width(4).height(4).fill('rgba(46, 48, 47, 0.10)').position({ x: 248, y: 210 })
      Circle().width(6).height(6).fill('rgba(46, 48, 47, 0.12)').position({ x: 146, y: 386 })
      Circle().width(4).height(4).fill('rgba(46, 48, 47, 0.08)').position({ x: 306, y: 634 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  WaterfallOrbitLines() {
    Stack() {
      Circle()
        .width(470)
        .height(470)
        .fill('rgba(255, 255, 255, 0.00)')
        .stroke('rgba(199, 201, 194, 0.46)')
        .strokeWidth(1)
        .position({ x: -312, y: 276 })

      Circle()
        .width(560)
        .height(560)
        .fill('rgba(255, 255, 255, 0.00)')
        .stroke('rgba(199, 201, 194, 0.24)')
        .strokeWidth(1)
        .position({ x: -360, y: 196 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FragmentWaterfallPage() {
    Stack() {
      Column() {
        this.WaterfallHeader()

        List({ space: 8 }) {
            ForEach(this.fragments, (item: FragmentItem) => {
              ListItem() {
                this.FragmentWaterfallItem(item)
              }
            }, (item: FragmentItem) => item.id)

          ListItem() {
            Column() {
              Blank()
                .height(190)
            }
            .width('100%')
          }
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .onScrollIndex((firstIndex: number, lastIndex: number) => {
          let centerIndex: number = Math.floor((firstIndex + lastIndex) / 2)
          if (centerIndex >= 0 && centerIndex < this.fragments.length) {
            this.activeIndex = centerIndex
            this.activeCommunityKey = 'root'
          }
        })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 22, right: 22, top: 50, bottom: 36 })

      Column() {
        Blank()

        Row() {
          Blank()
          this.WaterfallHintCard()
          Blank()
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(116)
      .padding({ left: 28, right: 28 })
      .position({ x: 0, y: '78%' })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  WaterfallHeader() {
    Row() {
      Column() {
        Text('个人碎片集合')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor('#252729')
          .letterSpacing(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text('滑动浏览被暂存的想法碎片')
          .fontSize(12)
          .fontColor('#9a9d97')
          .margin({ top: 7 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)

      Button('关系图  ↗')
        .width(102)
        .height(42)
        .fontSize(13)
        .fontColor('#343635')
        .backgroundColor('rgba(255, 255, 255, 0.76)')
        .borderRadius(21)
        .shadow({ radius: 20, color: 'rgba(44, 46, 45, 0.12)', offsetX: 0, offsetY: 10 })
        .onClick(() => {
          this.graphMode = true
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 24 })
  }

  @Builder
  FragmentWaterfallItem(item: FragmentItem) {
    Column() {
      Row() {
        Text(item.id)
          .fontSize(item.id === this.currentFragment().id ? 76 : 58)
          .fontWeight(FontWeight.Bold)
          .fontColor(item.id === this.currentFragment().id ? '#25272a' : '#dedfdb')
          .width(120)
          .textAlign(TextAlign.Start)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Column() {
          Text(item.tag)
            .fontSize(item.id === this.currentFragment().id ? 21 : 17)
            .fontWeight(FontWeight.Bold)
            .fontColor(item.id === this.currentFragment().id ? '#2c2e30' : '#979a95')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(item.text)
            .fontSize(item.id === this.currentFragment().id ? 18 : 15)
            .fontColor(item.id === this.currentFragment().id ? '#6b6f69' : '#a8aaa5')
            .lineHeight(item.id === this.currentFragment().id ? 30 : 24)
            .margin({ top: 8 })
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row() {
            Text(item.shared ? '匿名共享' : '仅自己可见')
              .fontSize(11)
              .fontColor('#b0b2ad')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(item.remind)
              .fontSize(11)
              .fontColor('#b0b2ad')
              .margin({ left: 16 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .margin({ top: 12 })
        }
        .layoutWeight(1)
        .padding({ left: 8, right: 4 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .padding({ top: item.id === this.currentFragment().id ? 22 : 16, bottom: item.id === this.currentFragment().id ? 22 : 16 })
    }
    .width('100%')
    .margin({ bottom: 2 })
  }

  @Builder
  WaterfallHintCard() {
    Text('上下滑动，居中碎片会自动高亮')
      .fontSize(14)
      .fontColor('#767974')
      .textAlign(TextAlign.Center)
      .width('100%')
      .height(52)
      .lineHeight(52)
      .padding({ left: 18, right: 18 })
      .backgroundColor('rgba(255, 255, 255, 0.86)')
      .border({ width: 1, color: 'rgba(56, 58, 57, 0.08)' })
      .borderRadius(26)
      .shadow({ radius: 24, color: 'rgba(44, 46, 45, 0.10)', offsetX: 0, offsetY: 12 })
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }

  @Builder
  PersonalGraph() {
    Column() {
      this.GraphHeader()
      this.GraphCard()

    }
    .width('100%')
    .height('100%')
    .padding({ left: 22, right: 22, top: 34, bottom: 74 })
  }

  @Builder
  GraphHeader() {
    Column() {
      Row() {
        Text('脑洞关系网')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#222425')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Blank()

        Button('返回碎片  ＋')
          .width(112)
          .height(38)
          .fontSize(13)
          .fontColor('#3d403d')
          .backgroundColor('rgba(255, 255, 255, 0.76)')
          .border({ width: 1, color: 'rgba(56, 58, 57, 0.08)' })
          .borderRadius(19)
          .shadow({ radius: 18, color: 'rgba(44, 46, 45, 0.10)', offsetX: 0, offsetY: 8 })
          .onClick(() => {
            this.graphMode = false
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Row() {
        Text('点击节点查看关系')
          .fontSize(12)
          .fontColor('#747873')
          .height(30)
          .lineHeight(30)
          .padding({ left: 12, right: 12 })
          .backgroundColor('rgba(255, 255, 255, 0.70)')
          .border({ width: 1, color: 'rgba(56, 58, 57, 0.08)' })
          .borderRadius(15)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
  }

  @Builder
  GraphCard() {
    Stack() {
      Canvas(this.graphCanvasContext)
      .width('100%')
      .height('100%')
      .onReady(() => {
        this.drawGraphCanvas()
      })
      .onTouch((event: TouchEvent) => {
        this.handleGraphCanvasTouch(event)
      })
    }
    .width('100%')
    .height(520)
    .margin({ top: 18 })
    .backgroundColor('rgba(241, 242, 238, 0.82)')
    .border({ width: 1, color: 'rgba(55, 57, 56, 0.05)' })
    .borderRadius(26)
    .clip(true)
  }

  @Builder
  GraphCurveEdge(edge: GraphEdge) {
    Stack() {
      this.GraphCurveSegment(edge, 0, 0.34)
      this.GraphCurveSegment(edge, 0.34, 0.68)
      this.GraphCurveSegment(edge, 0.68, 1)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  GraphCurveSegment(edge: GraphEdge, startT: number, endT: number) {
    Rect()
      .width(this.graphCurveSegmentLength(edge, startT, endT))
      .height(this.isGraphEdgeActive(edge) ? 4 : 1.4)
      .radius(3)
      .fill(edge.color)
      .opacity(this.isGraphEdgeActive(edge) ? 0.92 : 0.52)
      .rotate({ angle: this.graphCurveSegmentAngle(edge, startT, endT) })
      .position({ x: this.graphCurveX(edge, startT), y: this.graphCurveY(edge, startT) })
  }

  @Builder
  GraphNodeDot(node: GraphNode) {
    Column() {
      Circle()
        .width(24)
        .height(24)
        .fill(this.getToneColor(node.tone))
        .opacity(node.tone === 'micro' ? 0.48 : 0.88)
        .shadow({ radius: 18, color: 'rgba(44, 46, 45, 0.10)', offsetX: 0, offsetY: 8 })

      if (node.name.length > 0) {
        Text(node.name)
          .fontSize(11)
          .fontColor('#747873')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 7 })
      }
    }
    .width(74)
    .alignItems(HorizontalAlign.Center)
    .position({ x: this.graphX(node.x) - 25, y: this.graphY(node.y) - 8 })
    .onClick(() => {
      if (node.fragmentIndex >= 0) {
        this.activeIndex = node.fragmentIndex
        this.graphMode = false
      }
    })
  }

  @Builder
  CommunityPage() {
    Column() {
      this.TopBar('碎片延申树', 'Shared branches', false)

      Text('从当前碎片出发，点击节点逐个展开别人的相似、相反经验。')
        .fontSize(13)
        .fontColor('#9b9d98')
        .lineHeight(21)
        .margin({ top: 6, bottom: 10 })
        .alignSelf(ItemAlign.Start)

      // Outer Stack: decorative circle stays fixed, Scroll fills remaining space
      Stack() {
        Circle()
          .width(270)
          .height(270)
          .fill('rgba(151, 161, 156, 0.07)')
          .position({ x: 24, y: 152 })

        // Scroll wraps Canvas + Column together so lines scroll with nodes
        Scroll() {
          Stack({ alignContent: Alignment.Top }) {
            // Layer 0: Canvas draws connection lines — INSIDE Scroll so it scrolls with content
            Canvas(this.treeCanvasContext)
              .width('100%')
              .height('100%')
              .onReady(() => {
                setTimeout(() => {
                  this.drawTreeLines()
                }, 400)
              })

            // Layer 1: tree nodes laid out in Column of Rows
            Column({ space: 48 }) {
              ForEach(this.getNodesByLevel(), (levelNodes: CommunityNode[], levelIndex: number) => {
                Row({ space: 8 }) {
                  ForEach(levelNodes, (node: CommunityNode) => {
                    this.TreeNodeCard(node, levelIndex, this.getTreeMaxDepth())
                  }, (node: CommunityNode) => node.key)
                }
                .width('100%')
                .justifyContent(levelNodes.length <= 1 ? FlexAlign.Center : FlexAlign.SpaceEvenly)
              }, (levelNodes: CommunityNode[], levelIndex: number) => levelIndex.toString())
            }
            .width('100%')
            .padding({ top: 16, bottom: 24 })
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          // Track the inner Stack's position within the scroll viewport for coordinate conversion
          .onAreaChange((oldArea, newArea) => {
            this.treeContainerGlobalX = newArea.globalPosition.x as number
            this.treeContainerGlobalY = newArea.globalPosition.y as number
          })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .layoutWeight(1)

      this.SharedFragmentCard()
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24, top: 34, bottom: 64 })
  }

  // Returns the max depth (0-indexed) of the visible tree
  private getTreeMaxDepth(): number {
    let levels: CommunityNode[][] = this.getNodesByLevel()
    return levels.length - 1
  }

  @Builder
  TreeNodeCard(node: CommunityNode, depth: number, maxDepth: number) {
    Column() {
      Text(node.key === 'root' ? this.currentFragment().tag : node.title)
        .fontSize(node.key === 'root' ? 15 : 14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#4a4c4a')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(node.key === 'root' ? '当前碎片' : (this.childrenOf(node.key).length > 0 ? '点击展开' : node.tag))
        .fontSize(11)
        .fontColor('#a0a39d')
        .maxLines(1)
        .margin({ top: 6 })
    }
    .width(node.key === 'root' ? 120 : 100)
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor(this.activeCommunityKey === node.key ? 'rgba(255, 255, 255, 0.92)' : 'rgba(255, 255, 255, 0.82)')
    .borderRadius(16)
    .border({ width: 1, color: this.activeCommunityKey === node.key ? 'rgba(70, 72, 70, 0.22)' : 'rgba(70, 72, 70, 0.10)' })
    .shadow({ radius: this.activeCommunityKey === node.key ? 16 : 10, color: 'rgba(43, 45, 44, 0.10)', offsetX: 0, offsetY: 6 })
    .scale({ x: 1.0 - (maxDepth - depth) * 0.05, y: 1.0 - (maxDepth - depth) * 0.05 })
    .opacity(1.0 - (maxDepth - depth) * 0.12)
    .animation({ duration: 300, curve: Curve.EaseOut })
    .onAreaChange((oldArea, newArea) => {
      let gp = newArea.globalPosition
      this.treeNodePositions.set(node.key, new NodePosition(
        gp.x as number,
        gp.y as number,
        newArea.width as number,
        newArea.height as number
      ))
      this.treeRedrawTrigger++
    })
    .onClick(() => {
      this.selectCommunityNode(node.key)
      setTimeout(() => {
        this.drawTreeLines()
      }, 300)
    })
  }

  private communityNodeBg(tone: string): string {
    if (tone === 'blue') {
      return 'rgba(141, 159, 178, 0.18)'
    }
    if (tone === 'green') {
      return 'rgba(150, 164, 143, 0.18)'
    }
    if (tone === 'rose') {
      return 'rgba(170, 150, 153, 0.18)'
    }
    if (tone === 'slate') {
      return 'rgba(152, 155, 155, 0.18)'
    }
    return 'rgba(255, 255, 255, 0.82)'
  }

  private getNodesByLevel(): CommunityNode[][] {
    let levels: CommunityNode[][] = []
    let root: CommunityNode = this.communityNodes[0]
    let currentLevel: CommunityNode[] = [root]
    while (currentLevel.length > 0) {
      levels.push(currentLevel)
      let nextLevel: CommunityNode[] = []
      for (let node of currentLevel) {
        if (this.isExpanded(node.key)) {
          let children: CommunityNode[] = this.childrenOf(node.key)
          for (let child of children) {
            nextLevel.push(child)
          }
        }
      }
      currentLevel = nextLevel
    }
    return levels
  }

  private redrawTreeLines(): void {
    setTimeout(() => {
      this.drawTreeLines()
    }, 80)
  }

  private drawTreeLines(): void {
    let ctx: CanvasRenderingContext2D = this.treeCanvasContext
    let canvasWidth: number = ctx.width
    let canvasHeight: number = ctx.height
    if (canvasWidth <= 0 || canvasHeight <= 0) {
      return
    }
    ctx.clearRect(0, 0, canvasWidth, canvasHeight)

    let containerX: number = this.treeContainerGlobalX
    let containerY: number = this.treeContainerGlobalY

    for (let parentKey of this.expandedCommunityKeys) {
      let parentPos = this.treeNodePositions.get(parentKey)
      if (!parentPos) {
        continue
      }
      let children: CommunityNode[] = this.childrenOf(parentKey)
      if (children.length === 0) {
        continue
      }

      let parentCX: number = parentPos.x + parentPos.w / 2 - containerX
      let parentBottom: number = parentPos.y + parentPos.h - containerY

      let childInfos: ChildLineInfo[] = []
      for (let child of children) {
        let cp = this.treeNodePositions.get(child.key)
        if (!cp) {
          continue
        }
        childInfos.push(new ChildLineInfo(
          cp.x + cp.w / 2 - containerX,
          cp.y - containerY
        ))
      }
      if (childInfos.length === 0) {
        continue
      }

      let leftmost: number = childInfos[0].cx
      let rightmost: number = childInfos[0].cx
      for (let ci of childInfos) {
        if (ci.cx < leftmost) {
          leftmost = ci.cx
        }
        if (ci.cx > rightmost) {
          rightmost = ci.cx
        }
      }

      let midY: number = (parentBottom + childInfos[0].top) / 2

      ctx.beginPath()
      ctx.moveTo(parentCX, parentBottom)
      ctx.lineTo(parentCX, midY)
      ctx.strokeStyle = '#D3D3D3'
      ctx.lineWidth = 1
      ctx.stroke()

      ctx.beginPath()
      ctx.moveTo(leftmost, midY)
      ctx.lineTo(rightmost, midY)
      ctx.strokeStyle = '#D3D3D3'
      ctx.lineWidth = 1
      ctx.stroke()

      for (let ci of childInfos) {
        ctx.beginPath()
        ctx.moveTo(ci.cx, midY)
        ctx.lineTo(ci.cx, ci.top)
        ctx.strokeStyle = '#D3D3D3'
        ctx.lineWidth = 1
        ctx.stroke()
      }

      for (let ci of childInfos) {
        ctx.beginPath()
        ctx.arc(ci.cx, midY, 2.5, 0, Math.PI * 2)
        ctx.fillStyle = '#C0C0C0'
        ctx.fill()
      }
      ctx.beginPath()
      ctx.arc(parentCX, midY, 2.5, 0, Math.PI * 2)
      ctx.fillStyle = '#C0C0C0'
      ctx.fill()
    }
  }

  @Builder
  SharedFragmentCard() {
    Column() {
      Row() {
        Column() {
          Text(this.currentSharedNode().author)
            .fontSize(12)
            .fontColor('#a0a39d')
          Text(this.currentSharedNode().match)
            .fontSize(11)
            .fontColor('#b5b7b2')
            .margin({ top: 3 })
        }

        Blank()

        Text(this.currentSharedNode().tag)
          .fontSize(12)
          .fontColor('#8b8e88')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('rgba(247, 247, 243, 0.86)')
          .borderRadius(14)
      }
      .width('100%')

      Text(this.currentSharedNode().text)
        .fontSize(16)
        .fontColor('#6f726c')
        .lineHeight(25)
        .margin({ top: 14 })
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row() {
        Button('收进 Box')
          .layoutWeight(1)
          .height(46)
          .fontSize(14)
          .fontColor('#f7f7f4')
          .backgroundColor('#4a4c4a')
          .borderRadius(23)
          .onClick(() => {
            this.saveSharedFragment()
          })

        Button('继续延申')
          .layoutWeight(1)
          .height(46)
          .fontSize(14)
          .fontColor('#6b6e68')
          .backgroundColor('rgba(255, 255, 255, 0.80)')
          .borderRadius(23)
          .border({ width: 1, color: 'rgba(70, 72, 70, 0.08)' })
          .margin({ left: 12 })
          .onClick(() => {
            this.branchSharedFragment()
          })
      }
      .width('100%')
      .margin({ top: 18 })
    }
    .width('100%')
    .padding(18)
    .backgroundColor('rgba(255, 255, 255, 0.78)')
    .borderRadius(28)
    .border({ width: 1, color: 'rgba(45, 47, 46, 0.07)' })
    .shadow({ radius: 30, color: 'rgba(49, 52, 52, 0.12)', offsetX: 0, offsetY: 16 })
  }

  @Builder
  TopBar(title: string, subtitle: string, showGraphButton: boolean) {
    Column() {
      Row() {
        if (showGraphButton) {
          this.BrandBadge()
        } else {
          Text(title)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#353637')
        }

        Blank()

        if (showGraphButton) {
          Button(this.graphMode ? '◎' : '↘')
            .width(46)
            .height(46)
            .fontSize(21)
            .fontColor('#3f4140')
            .backgroundColor('rgba(255, 255, 255, 0.74)')
            .borderRadius(23)
            .shadow({ radius: 22, color: 'rgba(39, 40, 41, 0.10)', offsetX: 0, offsetY: 10 })
            .onClick(() => {
              this.graphMode = !this.graphMode
            })
        }
      }
      .width('100%')

      if (showGraphButton) {
        Text(title)
          .fontSize(this.graphMode ? 28 : 12)
          .fontWeight(this.graphMode ? FontWeight.Bold : FontWeight.Regular)
          .fontColor(this.graphMode ? '#333536' : '#babbb6')
          .letterSpacing(this.graphMode ? 0 : 1)
          .margin({ top: this.graphMode ? 24 : 12 })
      }

      Text(subtitle)
        .fontSize(showGraphButton ? 13 : 14)
        .fontColor('#8e918b')
        .lineHeight(22)
        .margin({ top: showGraphButton ? 6 : 8 })
        .alignSelf(ItemAlign.Start)
    }
    .width('100%')
  }

  @Builder
  InputSheet() {
    Column({ space: 24 }) {
      // 顶部标题行：左标题 + 右侧明显关闭按钮
      Row() {
        Text('放入碎片')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        Text('×')
          .width(40)
          .height(40)
          .fontSize(28)
          .fontWeight(FontWeight.Medium)
          .fontColor('#666666')
          .textAlign(TextAlign.Center)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .onClick(() => {
            this.showInputSheet = false
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // 纸条质感输入区：带纹理背景、微旋转、不对称阴影，模拟撕下来的纸张
      Column() {
        TextArea({ placeholder: '写下一句灵感、观察、经验或突然冒出的想法...', text: this.draftContent })
          .width('100%')
          .height(148)
          .fontSize(16)
          .fontColor('#333333')
          .placeholderColor('#A0A0A0')
          .backgroundColor(Color.Transparent)
          .border({ width: 0, color: '#00000000' })
          .borderRadius(12)
          .padding({ left: 20, right: 20, top: 16, bottom: 16 })
          .onChange((value: string) => {
            this.draftContent = value
          })
      }
      .width('100%')
      .backgroundColor('#FAFAF7')
      .borderRadius(12)
      .rotate({ angle: -1.8 })
      .shadow({ radius: 14, color: 'rgba(0, 0, 0, 0.10)', offsetX: 3, offsetY: 5 })

      // Tag 标签输入区
      Column({ space: 8 }) {
        Text('Tag')
          .fontSize(13)
          .fontColor('#77777D')
          .fontWeight(FontWeight.Medium)
          .width('100%')

        TextInput({ placeholder: '例如：通勤观察 / 情绪 / 灵感', text: this.draftTag })
          .width('100%')
          .height(52)
          .fontSize(16)
          .fontColor('#222222')
          .placeholderColor('#A0A0A0')
          .backgroundColor('#F7F7F7')
          .border({ width: 0, color: '#00000000' })
          .borderRadius(16)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.draftTag = value
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 提醒偏好单选区
      Column({ space: 12 }) {
        Text('提醒偏好')
          .fontSize(13)
          .fontColor('#77777D')
          .fontWeight(FontWeight.Medium)
          .width('100%')

        Row({ space: 12 }) {
          ForEach(['通勤', '睡前', '周末'], (item: string) => {
            this.RemindPill(item)
          }, (item: string) => item)
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 底部大按钮
      Button('完成存档')
        .width('100%')
        .height(56)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#2C2C2C')
        .borderRadius(28)
        .onClick(() => {
          this.archiveFragment()
        })
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 24, bottom: 32 })
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 28, topRight: 28 })
  }

  @Builder
  RemindPill(item: string) {
    Text(item)
      .fontSize(15)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.draftRemind === item ? '#5A5A85' : '#999999')
      .textAlign(TextAlign.Center)
      .height(44)
      .lineHeight(44)
      .layoutWeight(1)
      .backgroundColor(this.draftRemind === item ? '#EAEAF2' : '#F5F5F5')
      .borderRadius(22)
      .border({ width: 0, color: '#00000000' })
      .onClick(() => {
        this.draftRemind = item
      })
  }

  @Builder
  ShareSwitch() {
    Stack() {
      Rect()
        .width(48)
        .height(28)
        .radius(14)
        .fill(this.shareEnabled ? '#393b3a' : '#d9dad4')

      Circle()
        .width(22)
        .height(22)
        .fill('#ffffff')
        .shadow({ radius: 8, color: 'rgba(35, 36, 35, 0.12)', offsetX: 0, offsetY: 3 })
        .position({ x: this.shareEnabled ? 23 : 3, y: 3 })
    }
    .width(48)
    .height(28)
    .onClick(() => {
      this.shareEnabled = !this.shareEnabled
    })
  }

  @Builder
  PageDots() {
    Row() {
      this.PageDot(AppPage.BOX)
      this.PageDot(AppPage.COLLECTION)
      this.PageDot(AppPage.COMMUNITY)
    }
    .height(16)
    .position({ x: '43%', y: '94%' })
    .zIndex(20)
  }

  @Builder
  PageDot(page: AppPage) {
    Rect()
      .width(this.currentPage === page ? 18 : 6)
      .height(6)
      .radius(3)
      .fill(this.currentPage === page ? 'rgba(91, 94, 92, 0.72)' : 'rgba(45, 47, 46, 0.16)')
      .margin({ right: 7 })
  }

  @Builder
  Toast() {
    Text(this.toastText)
      .fontSize(13)
      .fontColor('#f7f7f4')
      .padding({ left: 18, right: 18, top: 10, bottom: 10 })
      .backgroundColor('rgba(48, 50, 49, 0.88)')
      .borderRadius(20)
      .position({ x: '31%', y: '86%' })
      .zIndex(120)
  }
}


