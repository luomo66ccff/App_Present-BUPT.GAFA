export class FragmentTheme {
  static readonly background: string = '#F8F7FC';
  static readonly card: string = '#FFFFFF';
  static readonly primary: string = '#6F59D9';
  static readonly echo: string = '#EBCB8B';
  static readonly network: string = '#9FD8C5';
  static readonly text: string = '#222028';
  static readonly secondary: string = '#777382';

  static stateColor(state: string): string {
    switch (state) {
      case 'ECHOING':
        return this.echo;
      case 'CONNECTED':
        return this.network;
      default:
        return '#E8E5F0';
    }
  }
}
