import { TimeItem } from "../../models";
import { http } from "./Http";
import { preferences } from "@kit.ArkData";
import { JSON } from "@kit.ArkTS";
import { logger } from "./Logger";

class Tracking {
  store: preferences.Preferences | null = null;
  dataKey: string = "time-list";
  list: TimeItem[] = [];

  getStore() {
    if (!this.store) {
      const context = AppStorage.get<Context>("context");
      const dataPreferences = preferences.getPreferencesSync(context, { name: "tracking-store" });
      this.store = dataPreferences;
    }
    return this.store;
  }

  async record(startTime: number, endTime: number, questionId: string) {
    const json = this.getStore().getSync(this.dataKey, "[]");
    const list = JSON.parse(json as string) as TimeItem[];
    list.push({ startTime, endTime, questionId });
    this.getStore().putSync(this.dataKey, JSON.stringify(list));
    await this.getStore().flush();
  }

  async report(force: boolean = false) {
    const json = this.getStore().getSync(this.dataKey, "[]");
    const list = JSON.parse(json as string) as TimeItem[];
    if (list.length >= 5 || (force && list.length)) {
      await http.request<null>({ url: "time/tracking", method: "post", data: { timeList: list } });
      this.getStore().deleteSync(this.dataKey);
      await this.getStore().flush();
    }
  }
}

export const tracking = new Tracking();