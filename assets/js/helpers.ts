export type Hook = {
  el?: HTMLElement;
  viewName?: string;
  /**
   * the element has been added to the DOM and its server LiveView has finished mounting
   */
  mounted?: () => void;
  beforeUpdate?: () => void;
  updated?: () => void;
  destroyed?: () => void;
  disconnected?: () => void;
  reconnected?: () => void;

  pushEvent?: (
    event: string,
    payload: object,
    onReply?: (reply: any, ref: number) => any
  ) => void;
  pushEventTo?: (
    selectorOrTarget: any,
    event: string,
    payload: object,
    onReply: (reply: any, ref: number) => any
  ) => void;
  handleEvent?: (event: string, callback: (payload: object) => void) => void;
};
