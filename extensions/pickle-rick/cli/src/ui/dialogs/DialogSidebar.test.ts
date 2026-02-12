import { mock, expect, test, describe, beforeEach } from "bun:test";
import { createMockRenderer, createMockSession, type MockRenderer } from "./test-utils.ts";
import type { CliRenderer } from "@opentui/core";

const mockDashboardDialog = {
  update: mock(() => {}),
  show: mock(() => {}),
  hide: mock(() => {}),
  isOpen: mock(() => false),
  root: { visible: false, add: mock(() => {}) },
  destroy: mock(() => {}),
};

mock.module("./DashboardDialog.js", () => ({
  DashboardDialog: class {
    constructor() { return mockDashboardDialog; }
  }
}));

describe("DialogSidebar", () => {
  let mockRenderer: MockRenderer;

  beforeEach(() => {
    mockRenderer = createMockRenderer();
    mockDashboardDialog.isOpen.mockReturnValue(false);
    // Clear mocks
    mockDashboardDialog.update.mockClear();
    mockDashboardDialog.show.mockClear();
    mockDashboardDialog.hide.mockClear();
  });

  test("should delegate to DashboardDialog", async () => {
    const { DialogSidebar } = await import("./DialogSidebar.ts");
    const ds = new DialogSidebar(mockRenderer as unknown as CliRenderer);
    
    const mockSession = createMockSession({ id: "test" });
    ds.update(mockSession);
    
    expect(mockDashboardDialog.update).toHaveBeenCalledWith(mockSession);
  });

  test("should handle show/hide", async () => {
    const { DialogSidebar } = await import("./DialogSidebar.ts");
    const ds = new DialogSidebar(mockRenderer as unknown as CliRenderer);
    
    ds.show();
    expect(mockDashboardDialog.show).toHaveBeenCalled();
    
    ds.hide();
    expect(mockDashboardDialog.hide).toHaveBeenCalled();
  });

  test("should check isOpen", async () => {
    const { DialogSidebar } = await import("./DialogSidebar.ts");
    const ds = new DialogSidebar(mockRenderer as unknown as CliRenderer);
    
    mockDashboardDialog.isOpen.mockReturnValue(true);
    expect(ds.isOpen()).toBe(true);
  });
});
