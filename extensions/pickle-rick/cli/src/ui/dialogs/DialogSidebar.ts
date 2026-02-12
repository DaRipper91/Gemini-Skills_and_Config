import { DashboardDialog } from "./DashboardDialog.js";
import { SessionData } from "../../types/tasks.js";
import { CliRenderer } from "@opentui/core";

export class DialogSidebar {
  private dashboardDialog: DashboardDialog;
  private useDialog = true;

  constructor(renderer: CliRenderer) {
    this.dashboardDialog = new DashboardDialog(renderer);
    
    // Add the dialog to the renderer root
    renderer.root.add(this.dashboardDialog.root);
  }

  public setUseDialog(use: boolean) {
    this.useDialog = use;
  }

  public update(session: SessionData, silent: boolean = false) {
    this.dashboardDialog.update(session);
    if (!silent && !this.dashboardDialog.isOpen()) {
      this.dashboardDialog.show();
    }
  }

  public show() {
    this.dashboardDialog.show();
  }

  public hide() {
    this.dashboardDialog.hide();
  }

  public isOpen(): boolean {
    return this.dashboardDialog.isOpen();
  }

  public showInput(placeholder?: string) {
    // Dialog doesn't support input
  }

  public hideInput() {
  }

  public focusInput() {
  }

  public get onHide() {
    return undefined;
  }

  public set onHide(callback: (() => void) | undefined) {
  }

  public get input() {
    return undefined;
  }

  public get root() {
    return this.dashboardDialog.root;
  }

  public get dialogComponent() {
    return this.dashboardDialog;
  }

  public destroy() {
    this.dashboardDialog.destroy();
  }
}
