import { createRouter, createWebHistory } from "vue-router";
import { ElMessage } from "element-plus";

const routes = [
  {
    path: "/",
    redirect: "/home",
  },
  {
    path: "/login",
    name: "Login",
    component: () => import("@/views/Login.vue"),
    meta: {
      title: "登录",
      requiresAuth: false,
    },
  },
  {
    path: "/register",
    name: "Register",
    component: () => import("@/views/Register.vue"),
    meta: {
      title: "注册",
      requiresAuth: false,
    },
  },
  {
    path: "/home",
    name: "Home",
    component: () => import("@/views/Home.vue"),
    meta: {
      title: "首页",
      requiresAuth: true,
    },
  },
  {
    path: "/dishes",
    name: "Dishes",
    component: () => import("@/views/Dishes.vue"),
    meta: {
      title: "菜品浏览",
      requiresAuth: true,
    },
  },
  {
    path: "/cart",
    name: "Cart",
    component: () => import("@/views/Cart.vue"),
    meta: {
      title: "购物车",
      requiresAuth: true,
    },
  },
  {
    path: "/orders",
    name: "Orders",
    component: () => import("@/views/Orders.vue"),
    meta: {
      title: "我的订单",
      requiresAuth: true,
    },
  },
  {
    path: "/profile",
    name: "Profile",
    component: () => import("@/views/Profile.vue"),
    meta: {
      title: "个人中心",
      requiresAuth: true,
    },
  },
  {
    path: "/exchange",
    name: "VoucherExchange",
    component: () => import("@/components/points/VoucherExchangePanel.vue"),
    meta: {
      title: "兑换中心",
      requiresAuth: true,
    },
  },
  {
    path: "/admin",
    name: "Admin",
    component: () => import("@/views/admin/Admin.vue"),
    meta: {
      title: "管理后台",
      requiresAuth: true,
      requiresAdmin: true,
      allowedRoles: ["ADMIN", "WINDOW_MANAGER"],
    },
    redirect: "/admin/dashboard",
    children: [
      {
        path: "dashboard",
        name: "AdminDashboard",
        component: () => import("@/views/admin/Dashboard.vue"),
        meta: {
          title: "数据看板",
          requiresAuth: true,
          requiresAdmin: true,
          allowedRoles: ["ADMIN", "WINDOW_MANAGER"],
        },
      },
      {
        path: "analysis",
        name: "AdvancedAnalysis",
        component: () => import("@/views/admin/AdvancedAnalysis.vue"),
        meta: {
          title: "高级分析",
          requiresAuth: true,
          requiresAdmin: true,
          allowedRoles: ["ADMIN"],
        },
      },
      {
        path: "dishes",
        name: "AdminDishes",
        component: () => import("@/views/admin/Dishes.vue"),
        meta: {
          title: "菜品管理",
          requiresAuth: true,
          requiresAdmin: true,
          allowedRoles: ["ADMIN", "WINDOW_MANAGER"],
        },
      },
      {
        path: "orders",
        name: "AdminOrders",
        component: () => import("@/views/admin/Orders.vue"),
        meta: {
          title: "订单管理",
          requiresAuth: true,
          requiresAdmin: true,
          allowedRoles: ["ADMIN", "WINDOW_MANAGER"],
        },
      },
      {
        path: "users",
        name: "AdminUsers",
        component: () => import("@/views/admin/Users.vue"),
        meta: {
          title: "用户管理",
          requiresAuth: true,
          requiresAdmin: true,
          allowedRoles: ["ADMIN"],
        },
      },
      {
        path: "reviews",
        name: "AdminReviews",
        component: () => import("@/views/admin/Reviews.vue"),
        meta: {
          title: "评价管理",
          requiresAuth: true,
          requiresAdmin: true,
          allowedRoles: ["ADMIN", "WINDOW_MANAGER"],
        },
      },
      {
        path: "announcements",
        name: "AdminAnnouncements",
        component: () => import("@/views/admin/Announcements.vue"),
        meta: {
          title: "公告管理",
          requiresAuth: true,
          requiresAdmin: true,
          allowedRoles: ["ADMIN"],
        },
      },
      {
        path: "promotions",
        name: "AdminPromotions",
        component: () => import("@/views/admin/Promotions.vue"),
        meta: {
          title: "促销管理",
          requiresAuth: true,
          requiresAdmin: true,
          allowedRoles: ["ADMIN", "WINDOW_MANAGER"],
        },
      },
      {
        path: "vouchers",
        name: "AdminVouchers",
        component: () => import("@/views/admin/Vouchers.vue"),
        meta: {
          title: "代金券管理",
          requiresAuth: true,
          requiresAdmin: true,
          allowedRoles: ["ADMIN"],
        },
      },
      {
        path: "voucher-exchanges",
        name: "AdminVoucherExchanges",
        component: () => import("@/views/admin/VoucherExchanges.vue"),
        meta: {
          title: "兑换订单",
          requiresAuth: true,
          requiresAdmin: true,
          allowedRoles: ["ADMIN"],
        },
      },
      {
        path: "windows",
        name: "AdminWindows",
        component: () => import("@/views/admin/Windows.vue"),
        meta: {
          title: "窗口管理",
          requiresAuth: true,
          requiresAdmin: true,
          allowedRoles: ["ADMIN", "WINDOW_MANAGER"],
        },
      },
      {
        path: "canteens",
        name: "AdminCanteens",
        component: () => import("@/views/admin/Canteens.vue"),
        meta: {
          title: "食堂管理",
          requiresAuth: true,
          requiresAdmin: true,
          allowedRoles: ["ADMIN"],
        },
      },
    ],
  },
  {
    path: "/:pathMatch(.*)*",
    name: "NotFound",
    redirect: "/home",
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// 路由守卫
router.beforeEach((to, from, next) => {
  // 设置页面标题
  if (to.meta.title) {
    document.title = `${to.meta.title} - 学校食堂菜品推荐系统`;
  }

  // 检查是否需要认证
  if (to.meta.requiresAuth) {
    const token = localStorage.getItem("token");
    if (!token) {
      // 未登录，重定向到登录页
      next("/login");
      return;
    }

    // 检查是否需要管理员权限
    if (to.meta.requiresAdmin) {
      const userRole = localStorage.getItem("userRole");
      if (userRole !== "ADMIN" && userRole !== "WINDOW_MANAGER") {
        // 非管理员用户尝试访问管理页面
        ElMessage.warning("您没有权限访问此页面");
        next("/home");
        return;
      }
      const role = userRole || "";
      const matched = to.matched || [];
      const matchWithAllowed = [...matched]
        .reverse()
        .find((record) => Array.isArray(record.meta?.allowedRoles));
      if (matchWithAllowed) {
        const allowedRoles = matchWithAllowed.meta.allowedRoles;
        if (!allowedRoles.includes(role)) {
          ElMessage.warning("您没有权限访问此页面");
          next("/home");
          return;
        }
      }
    }
  }

  // 如果已登录，不允许访问登录和注册页
  const token = localStorage.getItem("token");
  if (token && (to.name === "Login" || to.name === "Register")) {
    next("/home");
    return;
  }

  next();
});

// 路由后置守卫
router.afterEach((to, from) => {
  // 可以在这里添加页面访问统计等
});

export default router;
