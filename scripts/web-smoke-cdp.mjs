import { spawn } from "node:child_process";
import { existsSync, mkdtempSync, rmSync } from "node:fs";
import { createServer } from "node:net";
import { tmpdir } from "node:os";
import path from "node:path";

const repoRoot = path.resolve(import.meta.dirname, "..");
const vueRoot = path.join(repoRoot, "vue");
const defaultChromePaths = [
  "C:/Program Files/Google/Chrome/Application/chrome.exe",
  "C:/Program Files (x86)/Google/Chrome/Application/chrome.exe",
  "C:/Program Files/Microsoft/Edge/Application/msedge.exe",
  "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe",
];

const routes = [
  { path: "/login", label: "login" },
  { path: "/home", label: "student home", role: "USER" },
  { path: "/dishes", label: "student dishes", role: "USER" },
  { path: "/cart", label: "student cart", role: "USER" },
  { path: "/orders", label: "student orders", role: "USER" },
  { path: "/profile", label: "student profile", role: "USER" },
  { path: "/exchange", label: "voucher exchange", role: "USER" },
  { path: "/admin/dashboard", label: "admin dashboard", role: "ADMIN" },
  { path: "/admin/analysis", label: "admin analysis", role: "ADMIN" },
  { path: "/admin/orders", label: "admin orders", role: "ADMIN" },
  { path: "/admin/reviews", label: "admin reviews", role: "ADMIN" },
  { path: "/admin/vouchers", label: "admin vouchers", role: "ADMIN" },
];

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const withTimeout = (promise, timeoutMs, label) => {
  let timer;
  const timeout = new Promise((_, reject) => {
    timer = setTimeout(() => reject(new Error(`Timed out: ${label}`)), timeoutMs);
  });
  return Promise.race([promise, timeout]).finally(() => clearTimeout(timer));
};

const getFreePort = () =>
  new Promise((resolve, reject) => {
    const server = createServer();
    server.on("error", reject);
    server.listen(0, "127.0.0.1", () => {
      const address = server.address();
      const port = typeof address === "object" ? address.port : null;
      server.close();
      if (!port) reject(new Error("Unable to allocate a free local port"));
      else resolve(port);
    });
  });

const pickChrome = () => {
  const explicit = process.env.CHROME_PATH;
  if (explicit && existsSync(explicit)) return explicit;
  const found = defaultChromePaths.find((candidate) => existsSync(candidate));
  if (!found) {
    throw new Error("Chrome/Edge executable not found. Set CHROME_PATH to run Web smoke checks.");
  }
  return found;
};

const waitForHttpJson = async (url, timeoutMs = 15000) => {
  const started = Date.now();
  let lastError;
  while (Date.now() - started < timeoutMs) {
    try {
      const res = await fetch(url);
      if (res.ok) return res.json();
      lastError = new Error(`HTTP ${res.status} for ${url}`);
    } catch (error) {
      lastError = error;
    }
    await sleep(200);
  }
  throw lastError || new Error(`Timed out waiting for ${url}`);
};

const waitForHttpOk = async (url, timeoutMs = 20000) => {
  const started = Date.now();
  let lastError;
  while (Date.now() - started < timeoutMs) {
    try {
      const res = await fetch(url);
      if (res.ok) return;
      lastError = new Error(`HTTP ${res.status} for ${url}`);
    } catch (error) {
      lastError = error;
    }
    await sleep(200);
  }
  throw lastError || new Error(`Timed out waiting for ${url}`);
};

const stopProcessTree = (child) => {
  if (!child?.pid || child.killed) return;
  if (process.platform === "win32") {
    spawn("taskkill", ["/pid", String(child.pid), "/t", "/f"], { stdio: "ignore" });
    return;
  }
  child.kill();
};

class CdpSession {
  constructor(webSocketUrl) {
    this.webSocketUrl = webSocketUrl;
    this.nextId = 1;
    this.pending = new Map();
    this.handlers = new Map();
  }

  async connect() {
    this.ws = new WebSocket(this.webSocketUrl);
    await new Promise((resolve, reject) => {
      const timer = setTimeout(() => reject(new Error("Timed out connecting to Chrome CDP")), 10000);
      this.ws.addEventListener("open", () => {
        clearTimeout(timer);
        resolve();
      }, { once: true });
      this.ws.addEventListener("error", (event) => {
        clearTimeout(timer);
        reject(event.error || new Error("Chrome CDP WebSocket error"));
      }, { once: true });
    });
    this.ws.addEventListener("message", (event) => this.receive(event.data));
  }

  receive(rawMessage) {
    const message = JSON.parse(String(rawMessage));
    if (message.id && this.pending.has(message.id)) {
      const { resolve, reject } = this.pending.get(message.id);
      this.pending.delete(message.id);
      if (message.error) reject(new Error(message.error.message || JSON.stringify(message.error)));
      else resolve(message.result || {});
      return;
    }

    const handlers = this.handlers.get(message.method) || [];
    for (const handler of handlers) handler(message.params || {});
  }

  on(method, handler) {
    const handlers = this.handlers.get(method) || [];
    handlers.push(handler);
    this.handlers.set(method, handlers);
  }

  send(method, params = {}) {
    const id = this.nextId;
    this.nextId += 1;
    const payload = JSON.stringify({ id, method, params });
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.pending.delete(id);
        reject(new Error(`CDP command timed out: ${method}`));
      }, 10000);
      this.pending.set(id, {
        resolve: (value) => {
          clearTimeout(timer);
          resolve(value);
        },
        reject: (error) => {
          clearTimeout(timer);
          reject(error);
        },
      });
      this.ws.send(payload);
    });
  }

  close() {
    this.ws?.close();
  }
}

const jsonBody = (body) => Buffer.from(JSON.stringify(body)).toString("base64");

const today = "2026-06-07";
const demoUser = {
  id: 1,
  username: "demo_user",
  nickname: "演示用户",
  studentId: "20260001",
  role: "USER",
  points: 860,
};
const demoAdmin = {
  id: 99,
  username: "admin",
  nickname: "管理员",
  studentId: "admin",
  role: "ADMIN",
  points: 0,
};

const dishes = [
  {
    id: 1,
    name: "香菇滑鸡饭",
    price: 16,
    category: "MAIN_DISH",
    image: "/dishes/main_dish.svg",
    rating: 4.8,
    salesCount: 286,
    available: true,
    tags: ["热销", "鲜香"],
    windowName: "一食堂二楼",
  },
  {
    id: 2,
    name: "番茄牛腩面",
    price: 18,
    category: "MEAT_DISH",
    image: "/dishes/meat_dish.svg",
    rating: 4.7,
    salesCount: 241,
    available: true,
    tags: ["酸甜", "暖胃"],
    windowName: "风味面档",
  },
  {
    id: 3,
    name: "清炒时蔬",
    price: 9,
    category: "VEGETABLE",
    image: "/dishes/vegetable_dish.svg",
    rating: 4.5,
    salesCount: 168,
    available: true,
    tags: ["清爽"],
    windowName: "素食窗口",
  },
];

const orders = [
  {
    id: 101,
    orderNumber: "ORD20260607001",
    status: "PAID",
    totalAmount: 34,
    goodsAmount: 34,
    payableAmount: 34,
    voucherDeduction: 0,
    pickupType: "IMMEDIATE",
    createTime: `${today}T12:00:00`,
    items: [
      { dishId: 1, dishName: "香菇滑鸡饭", price: 16, quantity: 1, subtotal: 16 },
      { dishId: 2, dishName: "番茄牛腩面", price: 18, quantity: 1, subtotal: 18 },
    ],
  },
];

const dailyRows = Array.from({ length: 10 }, (_, index) => ({
  time: `6-${index + 1}`,
  date: `6-${index + 1}`,
  value: 1200 + index * 150,
  orderCount: 48 + index * 4,
  orderAmount: 1200 + index * 150,
  MAIN_DISH: 420 + index * 18,
  MEAT_DISH: 360 + index * 16,
  VEGETABLE: 190 + index * 8,
  SOUP: 110 + index * 6,
  SNACK: 90 + index * 5,
  DRINK: 160 + index * 7,
}));

const page = (content) => ({
  content,
  records: content,
  rows: content,
  totalElements: content.length,
  total: content.length,
  size: 10,
  number: 0,
});

const responseForApi = (requestUrl, method) => {
  const url = new URL(requestUrl);
  const pathname = url.pathname;
  const ok = (data) => ({ status: 200, body: { data } });
  const list = (data) => ({ status: 200, body: data });

  if (pathname.endsWith("/api/users/login")) {
    return ok({ token: "smoke-token", user: demoAdmin });
  }
  if (pathname.endsWith("/api/users/me")) return ok(demoUser);
  if (pathname === "/api/users" || pathname.endsWith("/api/users")) return ok(page([demoUser, demoAdmin]));
  if (pathname.includes("/api/users/dietary-tags")) return ok(["清淡", "微辣", "高蛋白"]);
  if (/\/api\/users\/\d+$/.test(pathname)) return ok(demoUser);

  if (pathname.includes("/api/dishes/categories")) return ok(["MAIN_DISH", "MEAT_DISH", "VEGETABLE"]);
  if (pathname.includes("/api/dishes/hot")) return ok(dishes);
  if (pathname.includes("/api/dishes/promotions")) return ok(dishes.slice(0, 2));
  if (pathname === "/api/dishes" || pathname.includes("/api/dishes/search")) return ok(page(dishes));
  if (/\/api\/dishes\/\d+\/ratings/.test(pathname)) return ok({ averageRating: 4.7, ratingCount: 36 });
  if (/\/api\/dishes\/\d+$/.test(pathname)) return ok(dishes[0]);

  if (pathname.includes("/api/windows/canteens") || pathname.endsWith("/api/canteens")) {
    return ok([{ id: 1, name: "一食堂" }, { id: 2, name: "二食堂" }]);
  }
  if (pathname.includes("/api/windows/canteen/")) {
    return ok([{ id: 1, name: "一食堂二楼", canteenId: 1 }]);
  }
  if (pathname.endsWith("/api/windows")) return ok([{ id: 1, name: "一食堂二楼", canteenId: 1 }]);

  if (pathname.endsWith("/api/orders/cart")) {
    if (method === "GET") return ok([{ id: 1, dish: dishes[0], price: 16, quantity: 1 }]);
    return ok({ success: true });
  }
  if (pathname.endsWith("/api/orders")) return ok(page(orders));
  if (/\/api\/orders\/\d+/.test(pathname)) return ok(orders[0]);
  if (pathname.includes("/api/payments/orders/")) {
    return ok({ status: "PAID", provider: "MOCK", transactionId: "SMOKE-TXN-001", amount: 34 });
  }

  if (pathname.includes("/api/points/balance")) return ok({ points: 860 });
  if (pathname.includes("/api/points/history")) {
    return ok(page([{ id: 1, type: "EARN", points: 20, description: "完成评价", createTime: `${today}T12:20:00` }]));
  }
  if (pathname.includes("/api/rewards/categories") || pathname.includes("/api/admin/vouchers/categories")) {
    return ok([{ id: 1, name: "代金券" }, { id: 2, name: "周边" }]);
  }
  if (pathname.includes("/api/rewards/page") || pathname.includes("/api/admin/vouchers/page")) {
    return ok(page([{ id: 1, name: "5元代金券", type: "VOUCHER", pointsRequired: 200, stock: 30, status: "AVAILABLE", category: { id: 1, name: "代金券" }, exchangeEnabled: true, faceValue: 5 }]));
  }
  if (pathname.includes("/api/rewards/exchanges/page") || pathname.includes("/api/admin/voucher-exchanges/page")) {
    return ok(page([{ id: 1, rewardName: "5元代金券", status: "CREATED", pointsCost: 200, createTime: `${today}T13:00:00` }]));
  }
  if (pathname.includes("/api/rewards/vouchers")) {
    return ok(page([{ id: 1, name: "5元代金券", faceValue: 5, minAmount: 20, status: "UNUSED" }]));
  }
  if (pathname.includes("/api/admin/voucher-exchanges/stats")) return ok({ total: 1, pending: 1 });

  if (pathname.includes("/api/promotions/stats")) return ok({ total: 2, active: 2, inactive: 0 });
  if (pathname.includes("/api/promotions/active")) return ok([{ id: 1, name: "午餐满减", type: "discount", discountValue: 0.8 }]);
  if (pathname.includes("/api/promotions/page") || pathname.includes("/api/promotions/search")) {
    return ok(page([{ id: 1, name: "午餐满减", type: "discount", discountValue: 0.8, status: "ACTIVE" }]));
  }
  if (pathname.includes("/api/combos")) return ok([]);

  if (pathname.includes("/api/announcements")) return ok([{ id: 1, title: "今日菜单更新", content: "欢迎体验智慧食堂。" }]);
  if (pathname.includes("/api/notifications/unread-count")) return ok(0);
  if (pathname.includes("/api/notifications")) return ok(page([]));

  if (pathname.includes("/api/reviews/stats")) {
    return ok({ totalReviews: 128, avgRating: 4.6, activeUsers: 86, reviewedOrders: 102 });
  }
  if (pathname.includes("/api/reviews/order/")) return ok([]);
  if (pathname.includes("/api/reviews/dish/") || pathname.endsWith("/api/reviews")) {
    return ok(page([{ id: 1, username: "demo_user", rating: 5, content: "好吃", createTime: `${today}T12:30:00`, status: "NORMAL" }]));
  }

  if (pathname.includes("/api/weather/current")) return ok({ temperature: 26, weather: "晴", humidity: 55 });
  if (pathname.includes("/api/recommendations")) return ok(dishes);

  if (pathname.includes("/api/statistics/metrics")) {
    return ok({ revenue: 45280, revenueChange: 12, orders: 2038, ordersChange: 8, users: 1268, usersChange: 5, avgOrderValue: 22, avgOrderChange: 3 });
  }
  if (pathname.includes("/api/statistics/dashboard-summary")) return ok({ totalUsers: 1268, todayOrders: 286, todayRevenue: 6420 });
  if (pathname.includes("/api/statistics/revenue-trend-detail")) return ok({ granularity: "day", data: dailyRows });
  if (pathname.includes("/api/statistics/revenue-trend")) return ok(dailyRows.map(({ time, value }) => ({ time, value })));
  if (pathname.includes("/api/statistics/orders-trend")) return ok(dailyRows.map(({ time, orderCount }) => ({ time, value: orderCount })));
  if (pathname.includes("/api/statistics/dish-sales-ranking-by-period")) {
    return ok(dailyRows.slice(-3).map((row) => ({ time: row.time, top: dishes.map((dish, index) => ({ name: dish.name, qty: 90 - index * 12 })) })));
  }
  if (pathname.includes("/api/statistics/dish-rating-ranking")) return ok(dishes.map((dish, index) => ({ name: dish.name, value: 4.8 - index * 0.2, reviewCount: 30, ratingCount: 36 })));
  if (pathname.includes("/api/statistics/dish-trend-ranking")) return ok(dishes.map((dish, index) => ({ name: dish.name, growthRate: 24 - index * 8, current: 100, previous: 80 })));
  if (pathname.includes("/api/statistics/dish-category-ranking")) return ok([{ category: "主食", top: dishes.map((dish) => ({ name: dish.name, value: dish.salesCount })) }]);
  if (pathname.includes("/api/statistics/user-active-periods")) return ok(Array.from({ length: 24 }, (_, hour) => ({ time: `${hour}-${hour + 1}`, value: hour === 12 ? 180 : 30 })));
  if (pathname.includes("/api/statistics/category-trend")) return ok(dailyRows);
  if (pathname.includes("/api/statistics/review-keywords")) return ok({ totalReviews: 128, matchedReviews: 120, keywords: [{ name: "好吃", value: 80 }, { name: "实惠", value: 45 }] });
  if (pathname.includes("/api/statistics/dish-features/wordcloud/version")) return ok({ version: 1 });
  if (pathname.includes("/api/statistics/dish-features/wordcloud/dishes")) return ok(dishes);
  if (pathname.includes("/api/statistics/dish-features/wordcloud")) return ok({ version: 1, matchedReviews: 120, coveredDishes: 12, keywords: [{ name: "鲜香", value: 88, category: "TASTE" }] });
  if (pathname.includes("/api/statistics/association-rules")) return ok([{ itemA: "香菇滑鸡饭", itemB: "柠檬茶", count: 86, support: 0.18, percentage: "18.0%" }]);
  if (pathname.includes("/api/statistics/user-segmentation/users")) return ok(page([{ username: "demo_user", totalSpent: 268, orderCount: 13, recencyDays: 1 }]));
  if (pathname.includes("/api/statistics/user-segmentation")) return ok({ summary: { totalUsers: 1268, avgSpent: 68, avgOrders: 4, avgRecency: 6 }, segments: [{ code: "VIP", count: 128, metrics: { avgSpend: 188, avgOrders: 11, avgRecencyDays: 2 } }] });
  if (pathname.includes("/api/statistics/inventory-warning")) return ok([{ dishName: "香菇滑鸡饭", date: today, sales: 182, stock: 18, totalSupply: 200, ratio: 0.91, alertMessage: "库存偏低" }]);
  if (pathname.includes("/api/statistics/comparison-analysis")) {
    return ok({ metrics1: { revenue: 1200, orders: 60, avgOrderValue: 20 }, metrics2: { revenue: 1500, orders: 70, avgOrderValue: 21 }, metrics: { revenue: { deltaPct: 25 }, orders: { deltaPct: 16 }, avgOrderValue: { deltaPct: 5 } }, breakdowns: { byCategory: [{ name: "主食", a: 400, b: 500, delta: 100, deltaPct: 25 }], byWindow: [], byDish: [] } });
  }
  if (pathname.includes("/api/statistics")) return ok([]);

  return list({ data: [] });
};

const installApiMock = (cdp, failures) => {
  cdp.on("Fetch.requestPaused", async (params) => {
    try {
      const url = new URL(params.request.url);
      if (!url.pathname.startsWith("/api/")) {
        await cdp.send("Fetch.continueRequest", { requestId: params.requestId });
        return;
      }
      const method = params.request.method || "GET";
      const mocked = responseForApi(params.request.url, method);
      await cdp.send("Fetch.fulfillRequest", {
        requestId: params.requestId,
        responseCode: mocked.status,
        responseHeaders: [{ name: "Content-Type", value: "application/json; charset=utf-8" }],
        body: jsonBody(mocked.body),
      });
    } catch (error) {
      failures.push({ source: "smoke-mock", message: error.message });
      await cdp.send("Fetch.fulfillRequest", {
        requestId: params.requestId,
        responseCode: 500,
        responseHeaders: [{ name: "Content-Type", value: "application/json; charset=utf-8" }],
        body: jsonBody({ error: error.message }),
      });
    }
  });
};

const buildPreloadScript = (role) => {
  const user = role === "ADMIN" ? demoAdmin : demoUser;
  if (!role) {
    return `
      localStorage.removeItem("token");
      localStorage.removeItem("userInfo");
      localStorage.removeItem("userRole");
      localStorage.removeItem("userId");
      sessionStorage.clear();
    `;
  }
  return `
    localStorage.setItem("token", "smoke-token");
    localStorage.setItem("userInfo", ${JSON.stringify(JSON.stringify(user))});
    localStorage.setItem("userRole", ${JSON.stringify(user.role)});
    localStorage.setItem("userId", ${JSON.stringify(String(user.id))});
    sessionStorage.clear();
  `;
};

const pageReady = async (cdp) => {
  const result = await withTimeout(cdp.send("Runtime.evaluate", {
    expression: `
      new Promise((resolve) => {
        const done = () => setTimeout(() => resolve({
          title: document.title,
          text: document.body.innerText.slice(0, 400),
          path: location.pathname,
        }), 900);
        if (document.readyState === "complete") done();
        else window.addEventListener("load", done, { once: true });
      })
    `,
    awaitPromise: true,
    returnByValue: true,
  }), 12000, "page ready");
  return result.result?.value || {};
};

const attachFailureCollectors = (cdp, failures) => {
  cdp.on("Runtime.consoleAPICalled", (params) => {
    if (!["error", "assert"].includes(params.type)) return;
    failures.push({
      source: "console",
      type: params.type,
      message: params.args?.map((arg) => arg.value || arg.description || arg.type).join(" ") || "",
    });
  });
  cdp.on("Runtime.exceptionThrown", (params) => {
    failures.push({
      source: "exception",
      message:
        params.exceptionDetails?.exception?.description ||
        params.exceptionDetails?.text ||
        "runtime exception",
    });
  });
  cdp.on("Log.entryAdded", (params) => {
    if (!["error"].includes(params.entry?.level)) return;
    failures.push({ source: "log", message: params.entry.text });
  });
};

const closeTarget = async (browserPort, targetId) => {
  if (!targetId) return;
  try {
    await fetch(`http://127.0.0.1:${browserPort}/json/close/${targetId}`);
  } catch (error) {
    // Target may already be closed during browser shutdown.
  }
};

const checkRoute = async ({ browserPort, baseUrl, route, failures }) => {
  const before = failures.length;
  let routeCdp = null;
  let targetId = "";
  console.log(`[web-smoke] checking ${route.label} ${route.path}`);

  try {
    const target = await fetch(`http://127.0.0.1:${browserPort}/json/new?about:blank`, {
      method: "PUT",
    }).then((res) => res.json());
    targetId = target.id;
    routeCdp = new CdpSession(target.webSocketDebuggerUrl);
    await withTimeout(routeCdp.connect(), 10000, "connect route target");
    attachFailureCollectors(routeCdp, failures);
    installApiMock(routeCdp, failures);

    await routeCdp.send("Page.enable");
    await routeCdp.send("Runtime.enable");
    await routeCdp.send("Log.enable");
    await routeCdp.send("Page.addScriptToEvaluateOnNewDocument", {
      source: `
        ${buildPreloadScript(route.role)}
        window.EventSource = class SmokeEventSource extends EventTarget {
          constructor(url) {
            super();
            this.url = url;
            this.readyState = 1;
            setTimeout(() => {
              if (typeof this.onopen === "function") this.onopen(new Event("open"));
            }, 0);
          }
          close() {
            this.readyState = 2;
          }
        };
      `,
    });
    await routeCdp.send("Fetch.enable", {
      patterns: [{ urlPattern: `${baseUrl}/api/*`, requestStage: "Request" }],
    });

    try {
      await withTimeout(
        routeCdp.send("Page.navigate", { url: `${baseUrl}${route.path}` }),
        12000,
        `navigate ${route.path}`,
      );
    } catch (error) {
      if (!String(error?.message || "").includes("Page.navigate")) {
        throw error;
      }
      console.log(`[web-smoke] navigation response slow for ${route.path}; checking rendered DOM`);
      await sleep(1200);
    }
    const snapshot = await pageReady(routeCdp);
    if (!snapshot.text || snapshot.text.length < 5) {
      failures.push({ source: "smoke", message: `${route.label} rendered empty body` });
    }
  } catch (error) {
    failures.push({ source: "smoke", message: `${route.label} failed: ${error.message}` });
  } finally {
    routeCdp?.close();
    await closeTarget(browserPort, targetId);
  }

  const added = failures.length - before;
  console.log(`[web-smoke] ${added === 0 ? "PASS" : "FAIL"} ${route.label} ${route.path}`);
};

const run = async () => {
  const chromePath = pickChrome();
  const vitePort = await getFreePort();
  const browserPort = await getFreePort();
  const viteCli = path.join(vueRoot, "node_modules", "vite", "bin", "vite.js");
  const vite = spawn(process.execPath, [viteCli, "--host", "127.0.0.1", "--port", String(vitePort), "--strictPort"], {
    cwd: vueRoot,
    env: {
      ...process.env,
      VITE_API_BASE: "",
      VITE_ADMIN_DEMO_DATA: "true",
      BROWSER: "none",
    },
    stdio: ["ignore", "pipe", "pipe"],
  });

  let chrome;
  let userDataDir;
  const failures = [];

  try {
    console.log(`[web-smoke] starting Vite on ${vitePort}`);
    await waitForHttpOk(`http://127.0.0.1:${vitePort}/`);
    console.log(`[web-smoke] starting browser on ${browserPort}`);
    userDataDir = mkdtempSync(path.join(tmpdir(), "canteen-web-smoke-"));
    chrome = spawn(chromePath, [
      "--headless=new",
      "--disable-gpu",
      "--no-first-run",
      "--no-default-browser-check",
      "--disable-background-networking",
      `--user-data-dir=${userDataDir}`,
      `--remote-debugging-port=${browserPort}`,
      "about:blank",
    ], { stdio: ["ignore", "ignore", "pipe"] });

    await waitForHttpJson(`http://127.0.0.1:${browserPort}/json/version`);
    const baseUrl = `http://127.0.0.1:${vitePort}`;

    const routeLimit = Number(process.env.SMOKE_ROUTE_LIMIT || routes.length);
    const selectedRoutes = routes.slice(0, routeLimit);
    for (const route of selectedRoutes) {
      await checkRoute({ browserPort, baseUrl, route, failures });
    }

    if (failures.length > 0) {
      console.error("\nWeb smoke failures:");
      failures.forEach((failure, index) => {
        console.error(`${index + 1}. [${failure.source}] ${failure.message}`);
      });
      process.exitCode = 1;
      return;
    }

    console.log(`\nWeb smoke passed: ${selectedRoutes.length} routes, console errors: 0`);
  } finally {
    stopProcessTree(chrome);
    stopProcessTree(vite);
    await sleep(500);
    if (userDataDir) {
      try {
        rmSync(userDataDir, { recursive: true, force: true, maxRetries: 5, retryDelay: 200 });
      } catch (error) {
        console.warn(`Unable to remove temporary Chrome profile: ${userDataDir}`);
      }
    }
  }
};

run().catch((error) => {
  console.error(error);
  process.exit(1);
});
