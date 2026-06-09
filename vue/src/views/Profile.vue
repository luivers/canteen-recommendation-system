<template>
  <div class="profile-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">个人中心</h1>
      <p class="page-subtitle">管理您的个人信息和偏好设置</p>
    </div>

    <!-- 个人中心内容 -->
    <el-card class="profile-card">
      <div class="profile-tabs">
        <!-- 标签页导航 -->
        <el-tabs v-model="activeTab" class="profile-tabs-nav">
          <el-tab-pane label="个人资料" name="info">
            <!-- 个人资料表单 -->
            <div class="tab-content">
              <el-form
                :model="userForm"
                label-width="100px"
                class="profile-form"
              >
                <el-form-item label="头像">
                  <el-upload
                    class="avatar-uploader"
                    action="#"
                    :show-file-list="false"
                    :before-upload="beforeAvatarUpload"
                    :http-request="handleAvatarUpload"
                  >
                    <div v-if="userForm.avatar" class="avatar-wrapper">
                      <img :src="getImageUrl(userForm.avatar)" class="avatar" />
                      <div class="avatar-mask">
                        <el-icon><Plus /></el-icon>
                        <span>更换头像</span>
                      </div>
                    </div>
                    <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
                  </el-upload>
                </el-form-item>
                <el-form-item label="用户名">
                  <el-input v-model="userForm.username" placeholder="用户名" />
                </el-form-item>
                <el-form-item label="手机号">
                  <el-input v-model="userForm.phone" placeholder="手机号" />
                </el-form-item>
                <el-form-item label="邮箱">
                  <el-input v-model="userForm.email" placeholder="邮箱" />
                </el-form-item>
                <el-form-item>
                  <el-button
                    type="primary"
                    :loading="saving"
                    @click="saveUserInfo"
                    >保存信息</el-button
                  >
                </el-form-item>
              </el-form>
            </div>
          </el-tab-pane>

          <el-tab-pane label="修改密码" name="password">
            <div class="tab-content">
              <el-form
                ref="passwordFormRef"
                :model="passwordForm"
                :rules="passwordRules"
                label-width="100px"
                class="profile-form"
              >
                <el-form-item label="原密码" prop="oldPassword">
                  <el-input
                    v-model="passwordForm.oldPassword"
                    type="password"
                    placeholder="请输入原密码"
                    show-password
                  />
                </el-form-item>
                <el-form-item label="新密码" prop="newPassword">
                  <el-input
                    v-model="passwordForm.newPassword"
                    type="password"
                    placeholder="请输入新密码（不少于6位）"
                    show-password
                  />
                </el-form-item>
                <el-form-item label="确认新密码" prop="confirmPassword">
                  <el-input
                    v-model="passwordForm.confirmPassword"
                    type="password"
                    placeholder="请再次输入新密码"
                    show-password
                  />
                </el-form-item>
                <el-form-item>
                  <el-button
                    type="primary"
                    :loading="savingPassword"
                    @click="changePassword"
                    >修改密码</el-button
                  >
                </el-form-item>
              </el-form>
            </div>
          </el-tab-pane>

          <el-tab-pane label="偏好设置" name="preferences">
            <!-- 偏好设置表单 -->
            <div class="tab-content">
              <el-form
                :model="preferencesForm"
                label-width="100px"
                class="preferences-form"
              >
                <!-- 口味偏好 -->
                <div class="section">
                  <h3 class="section-title">口味偏好</h3>

                  <!-- 辣度设置 -->
                  <el-form-item label="辣度">
                    <div class="slider-container">
                      <el-slider
                        v-model="preferencesForm.spicinessLevel"
                        :min="1"
                        :max="5"
                        :marks="{
                          1: '不辣',
                          2: '微辣',
                          3: '适中',
                          4: '很辣',
                          5: '爆辣',
                        }"
                      />
                      <span class="slider-value">{{
                        getSpicinessText(preferencesForm.spicinessLevel)
                      }}</span>
                    </div>
                  </el-form-item>

                  <!-- 甜度设置 -->
                  <el-form-item label="甜度">
                    <div class="slider-container">
                      <el-slider
                        v-model="preferencesForm.sweetnessLevel"
                        :min="1"
                        :max="5"
                        :marks="{
                          1: '不甜',
                          2: '微甜',
                          3: '适中',
                          4: '很甜',
                          5: '超甜',
                        }"
                      />
                      <span class="slider-value">{{
                        getSweetnessText(preferencesForm.sweetnessLevel)
                      }}</span>
                    </div>
                  </el-form-item>

                  <!-- 其他味觉偏好 -->
                  <el-form-item label="其他味觉">
                    <el-checkbox-group
                      v-model="preferencesForm.dietaryTags"
                      class="category-tags"
                    >
                      <el-checkbox label="清淡" class="tag-checkbox" />
                      <el-checkbox label="重口" class="tag-checkbox" />
                      <el-checkbox label="鲜香" class="tag-checkbox" />
                      <el-checkbox label="适中" class="tag-checkbox" />
                    </el-checkbox-group>
                  </el-form-item>
                </div>

                <!-- 饮食标签 -->
                <div class="section">
                  <h3 class="section-title">饮食标签</h3>

                  <el-form-item label="">
                    <el-skeleton :loading="loadingTags" animated>
                      <div v-if="!loadingTags" class="tag-categories">
                        <!-- 动态生成分类的标签组 -->
                        <div
                          v-for="(tags, category) in groupedTags"
                          :key="category"
                          class="tag-category"
                        >
                          <h4 class="category-title">{{ category }}</h4>
                          <el-checkbox-group
                            v-model="preferencesForm.dietaryTags"
                            class="category-tags"
                          >
                            <el-checkbox
                              v-for="tag in tags"
                              :key="tag"
                              :label="tag"
                              class="tag-checkbox"
                            />
                          </el-checkbox-group>
                        </div>

                        <!-- 如果没有任何标签 -->
                        <div
                          v-if="Object.keys(groupedTags).length === 0"
                          class="no-tags"
                        >
                          <p>暂无可用的饮食标签</p>
                        </div>
                      </div>
                    </el-skeleton>
                  </el-form-item>

                  <!-- 忌口信息 -->
                  <el-form-item label="忌口信息">
                    <el-input
                      v-model="preferencesForm.dietaryRestrictions"
                      type="textarea"
                      :rows="3"
                      placeholder="请输入您的忌口信息，如：不吃香菜、海鲜过敏等"
                    />
                  </el-form-item>
                </div>

                <!-- 提交按钮 -->
                <div class="form-actions">
                  <el-button @click="resetPreferences">重置</el-button>
                  <el-button
                    type="primary"
                    :loading="saving"
                    @click="savePreferences"
                    >保存设置</el-button
                  >
                </div>
              </el-form>
            </div>
          </el-tab-pane>

          <el-tab-pane label="积分中心" name="points">
            <div class="tab-content">
              <!-- 积分概览 -->
              <div class="points-overview">
                <div class="points-header">
                  <span class="points-label">当前可用积分</span>
                  <el-tooltip
                    content="通过评价菜品、参与活动获取积分，积分可用于兑换奖励"
                    placement="top"
                  >
                    <el-icon class="info-icon"><InfoFilled /></el-icon>
                  </el-tooltip>
                </div>
                <div class="points-value">{{ currentPoints }}</div>
                <div class="points-actions">
                  <el-button
                    type="primary"
                    plain
                    size="small"
                    @click="refreshPoints"
                    >刷新</el-button
                  >
                  <el-button
                    type="success"
                    plain
                    size="small"
                    @click="goToExchange"
                    >兑换</el-button
                  >
                </div>
              </div>

              <!-- 积分历史 -->
              <div class="points-history">
                <h3 class="section-title">积分明细</h3>
                <div v-if="loadingPoints" class="loading-container">
                  <el-skeleton :rows="5" animated />
                </div>
                <div v-else-if="pointHistory.length === 0" class="empty-state">
                  <el-empty description="暂无积分记录" />
                </div>
                <el-timeline v-else>
                  <el-timeline-item
                    v-for="log in pointHistory"
                    :key="log.id"
                    :timestamp="formatTime(log.createTime)"
                    :type="log.type === 'EARN' ? 'success' : 'warning'"
                    :hollow="true"
                  >
                    <div class="history-item">
                      <div class="history-content">
                        <div class="history-title">{{ log.description }}</div>
                        <div class="history-source">
                          {{ formatSource(log.source) }}
                        </div>
                      </div>
                      <div
                        class="history-value"
                        :class="log.type === 'EARN' ? 'earn' : 'spend'"
                      >
                        {{ log.type === "EARN" ? "+" : "" }}{{ log.points }}
                      </div>
                    </div>
                  </el-timeline-item>
                </el-timeline>

                <!-- 分页 -->
                <div v-if="totalPointsLogs > 0" class="pagination-container">
                  <el-pagination
                    v-model:current-page="currentPage"
                    background
                    layout="prev, pager, next"
                    :total="totalPointsLogs"
                    :page-size="pageSize"
                    @current-change="handlePageChange"
                  />
                </div>
              </div>
            </div>
          </el-tab-pane>
          <el-tab-pane label="消息通知" name="notifications">
            <div class="tab-content">
              <div class="notify-toolbar">
                <el-select
                  v-model="notifFilterType"
                  placeholder="全部类型"
                  clearable
                  style="width: 160px"
                  @change="handleNotifTypeChange"
                >
                  <el-option label="菜品" value="DISH" />
                  <el-option label="促销" value="PROMOTION" />
                  <el-option label="订单" value="RESERVATION" />
                  <el-option label="评价" value="COMMENT" />
                </el-select>
                <el-button
                  type="primary"
                  plain
                  size="small"
                  @click="loadNotifications"
                >
                  刷新
                </el-button>
                <el-button
                  type="success"
                  plain
                  size="small"
                  @click="handleMarkAllAsRead"
                >
                  全部已读
                </el-button>
                <el-button
                  type="danger"
                  plain
                  size="small"
                  @click="handleDeleteRead"
                >
                  删除已读
                </el-button>
                <el-tag class="unread-badge" type="warning" effect="plain">
                  未读 {{ unreadCount }}
                </el-tag>
              </div>

              <el-table v-loading="notifLoading" :data="notifications">
                <el-table-column label="标题" min-width="200">
                  <template #default="scope">
                    <div
                      style="display: flex; align-items: center; gap: 8px"
                    >
                      <el-tag
                        v-if="!scope.row.isRead"
                        size="small"
                        type="danger"
                        effect="plain"
                        >未读</el-tag
                      >
                      <span>{{ scope.row.title }}</span>
                    </div>
                  </template>
                </el-table-column>
                <el-table-column label="类型" width="100">
                  <template #default="scope">
                    {{ formatNotificationType(scope.row.type) }}
                  </template>
                </el-table-column>
                <el-table-column label="时间" width="180">
                  <template #default="scope">
                    {{ formatTime(scope.row.createTime) }}
                  </template>
                </el-table-column>
                <el-table-column label="操作" width="180">
                  <template #default="scope">
                    <el-button
                      size="small"
                      @click="openNotification(scope.row)"
                    >
                      查看
                    </el-button>
                    <el-button
                      size="small"
                      type="success"
                      :disabled="scope.row.isRead"
                      @click="handleMarkRead(scope.row)"
                    >
                      已读
                    </el-button>
                  </template>
                </el-table-column>
              </el-table>

              <div v-if="notifTotal === 0" class="empty-state">
                <el-empty description="暂无消息通知" />
              </div>
              <div v-else class="pagination-container">
                <el-pagination
                  v-model:current-page="notifPage"
                  background
                  layout="prev, pager, next"
                  :total="notifTotal"
                  :page-size="notifSize"
                  @current-change="handleNotifPageChange"
                />
              </div>
            </div>
          </el-tab-pane>
        </el-tabs>
      </div>
    </el-card>
  </div>

  <el-dialog
    v-model="notifDialogVisible"
    :title="selectedNotification?.title"
    width="520px"
  >
    <div class="notify-detail">
      <div>{{ selectedNotification?.content }}</div>
      <div style="margin-top: 12px; color: #909399">
        {{ formatTime(selectedNotification?.createTime) }}
      </div>
    </div>
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="notifDialogVisible = false">关闭</el-button>
        <el-button
          type="primary"
          @click="goToBiz(selectedNotification)"
        >
          去看看
        </el-button>
      </span>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, onMounted, computed, watch } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import { InfoFilled, Plus } from "@element-plus/icons-vue";
import api, { resolveStaticUrl } from "@/api/index";
import { useUserStore } from "@/stores/user";
import { userApi } from "@/api/user";
import dayjs from "dayjs";
import { rewardsApi } from "@/api/rewards";
import { notificationApi } from "@/api/notification";

const saving = ref(false);
const loadingTags = ref(false);
const userStore = useUserStore();
const activeTab = ref("info");
const router = useRouter();

// 积分相关
const currentPoints = ref(0);
const loadingPoints = ref(false);
const pointHistory = ref([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalPointsLogs = ref(0);

// 格式化时间
const formatTime = (time) => {
  return dayjs(time).format("YYYY-MM-DD HH:mm:ss");
};

// 格式化来源
const formatSource = (source) => {
  const map = {
    REVIEW_REWARD: "评价奖励",
    EXCHANGE: "积分兑换",
    ORDER: "订单消费",
    OTHER: "其他",
  };
  return map[source] || source;
};

// 加载积分历史
const loadPointHistory = async () => {
  try {
    loadingPoints.value = true;
    const response = await rewardsApi.getPointHistory({
      page: currentPage.value - 1,
      size: pageSize.value,
    });

    if (response.status === 200 && response.data) {
      pointHistory.value = response.data.data;
      totalPointsLogs.value = response.data.total;
    }
  } catch (error) {
    console.error("加载积分历史失败:", error);
    ElMessage.error("加载积分历史失败");
  } finally {
    loadingPoints.value = false;
  }
};

const loadPointBalance = async () => {
  try {
    const res = await rewardsApi.getPointBalance();
    const points = res?.data?.data?.points;
    currentPoints.value =
      typeof points === "number" ? points : Number(points || 0);
  } catch (e) {
    currentPoints.value = currentPoints.value || 0;
  }
};

// 刷新积分
const refreshPoints = () => {
  loadPointBalance();
  currentPage.value = 1;
  loadPointHistory();
};

const goToExchange = () => {
  router.push("/exchange");
};

// 分页变化
const handlePageChange = (page) => {
  currentPage.value = page;
  loadPointHistory();
};

// 用户信息表单
const userForm = reactive({
  username: "",
  studentId: "",
  role: "",
  phone: "",
  email: "",
  avatar: "",
});

// 偏好设置表单
const preferencesForm = reactive({
  spicinessLevel: 3,
  sweetnessLevel: 3,
  dietaryRestrictions: "",
  dietaryTags: [],
});

// 修改密码表单
const passwordFormRef = ref(null);
const savingPassword = ref(false);
const passwordForm = reactive({
  oldPassword: "",
  newPassword: "",
  confirmPassword: "",
});

const validatePass2 = (rule, value, callback) => {
  if (value === "") {
    callback(new Error("请再次输入新密码"));
  } else if (value !== passwordForm.newPassword) {
    callback(new Error("两次输入密码不一致!"));
  } else {
    callback();
  }
};

const passwordRules = {
  oldPassword: [
    { required: true, message: "请输入原密码", trigger: "blur" },
  ],
  newPassword: [
    { required: true, message: "请输入新密码", trigger: "blur" },
    { min: 6, message: "密码长度不能少于6位", trigger: "blur" },
  ],
  confirmPassword: [
    { required: true, validator: validatePass2, trigger: "blur" },
  ],
};

// 所有可用的饮食标签
const allDietaryTags = ref([]);

// 预设的标签分类
const tagCategories = {
  菜系偏好: [
    "川菜",
    "粤菜",
    "湘菜",
    "鲁菜",
    "苏菜",
    "浙菜",
    "闽菜",
    "徽菜",
    "东北菜",
    "西北菜",
    "家常菜",
  ],
  饮食类型: [
    "素食",
    "健身餐",
    "健康",
    "低脂",
    "高蛋白",
    "低碳水",
    "低糖",
    "清真",
    "无麸质",
  ],
};

// 获取图片URL
const getImageUrl = (url) => {
  return resolveStaticUrl(url);
};

// 图片上传前检查
const beforeAvatarUpload = (file) => {
  const isJPG = file.type === "image/jpeg";
  const isPNG = file.type === "image/png";
  const isLt2M = file.size / 1024 / 1024 < 2;

  if (!isJPG && !isPNG) {
    ElMessage.error("图片只能是 JPG 或 PNG 格式!");
    return false;
  }
  if (!isLt2M) {
    ElMessage.error("图片大小不能超过 2MB!");
    return false;
  }
  return true;
};

// 处理图片上传
const handleAvatarUpload = async (options) => {
  const file = options.file;
  const formData = new FormData();
  formData.append("file", file);

  try {
    const res = await api.post("/api/upload", formData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });
    
    if (res.data && res.data.url) {
      userForm.avatar = res.data.url;
      ElMessage.success("头像上传成功，请点击保存信息生效");
    }
  } catch (error) {
    console.error("头像上传失败:", error);
    ElMessage.error("头像上传失败");
  }
};

// 获取辣度文本
const getSpicinessText = (level) => {
  const texts = {
    1: "不辣",
    2: "微辣",
    3: "适中",
    4: "很辣",
    5: "爆辣",
  };
  return texts[level] || "适中";
};

// 获取甜度文本
const getSweetnessText = (level) => {
  const texts = {
    1: "不甜",
    2: "微甜",
    3: "适中",
    4: "很甜",
    5: "超甜",
  };
  return texts[level] || "适中";
};

// 保存用户信息
const saveUserInfo = async () => {
  try {
    saving.value = true;
    // 调用API保存用户信息
    const userId = localStorage.getItem("userId");
    if (!userId) {
      ElMessage.error("请先登录");
      return;
    }

    // 调用API保存用户信息
    const response = await api.put(`/api/users/${userId}`, {
        username: userForm.username,
        email: userForm.email,
        phone: userForm.phone,
        avatar: userForm.avatar
    });
    if (response.status === 200) {
      ElMessage.success("用户信息保存成功");
      // 更新本地存储的用户信息，以便导航栏头像能即时更新
      const userInfo = JSON.parse(localStorage.getItem("userInfo") || "{}");
      userInfo.avatar = userForm.avatar;
      userInfo.phone = userForm.phone;
      userInfo.email = userForm.email;
      localStorage.setItem("userInfo", JSON.stringify(userInfo));
      userStore.updateUserInfo({
        avatar: userForm.avatar,
        phone: userForm.phone,
        email: userForm.email,
      });
      
      // 触发 storage 事件，通知其他组件更新（在同一标签页中通常需要手动通知或使用 store）
      // 这里简单刷新页面或使用 store 会更好，但直接修改 localStorage 后，UserNavBar 的计算属性不会自动响应
      // 除非 UserNavBar 监听了 storage 事件或者使用了 Pinia
      // 由于 UserNavBar 使用 computed 读取 localStorage，这通常是非响应式的
      // 我们强制刷新一下页面，或者更好的是使用 Pinia 来管理用户信息
      // 这里先尝试更新 localStorage，并在 UserNavBar 中添加 storage 监听
      window.dispatchEvent(new Event("storage"));
    } else {
      ElMessage.error("保存失败，请稍后重试");
    }
  } catch (error) {
    console.error("保存用户信息失败:", error);
    ElMessage.error("保存失败，请稍后重试");
  } finally {
    saving.value = false;
  }
};

// 重置偏好设置
const resetPreferences = () => {
  preferencesForm.spicinessLevel = 3;
  preferencesForm.sweetnessLevel = 3;
  preferencesForm.dietaryRestrictions = "";
  preferencesForm.dietaryTags = [];
};

const sanitizeDietaryTags = (tags, dietaryRestrictions = "") => {
  const normalizedRestriction = String(dietaryRestrictions || "").trim();
  return Array.from(
    new Set(
      (Array.isArray(tags) ? tags : [])
        .map((tag) => String(tag || "").trim())
        .filter(Boolean)
        .filter((tag) => !tag.startsWith("辣度:"))
        .filter((tag) => !tag.startsWith("甜度:"))
        .filter((tag) => !normalizedRestriction || tag !== normalizedRestriction),
    ),
  );
};

const normalizeTagList = (payload) => {
  const raw =
    payload?.data?.data ??
    payload?.data?.content ??
    payload?.data?.records ??
    payload?.data ??
    payload?.content ??
    payload?.records ??
    payload;
  if (!Array.isArray(raw)) return [];
  return raw
    .map((item) =>
      typeof item === "string"
        ? item
        : item?.name || item?.tagName || item?.label || "",
    )
    .map((item) => String(item).trim())
    .filter(Boolean);
};

// 保存偏好设置
const savePreferences = async () => {
  try {
    saving.value = true;
    const userId = localStorage.getItem("userId");
    if (!userId) {
      ElMessage.error("请先登录");
      return;
    }

    // 调用API保存偏好设置，将数据放在请求体中，确保数组能够正确传递
    // 确保数值类型正确
    const preferencesData = {
      spicinessLevel: parseInt(preferencesForm.spicinessLevel),
      sweetnessLevel: parseInt(preferencesForm.sweetnessLevel),
      dietaryRestrictions: preferencesForm.dietaryRestrictions,
      dietaryTags: sanitizeDietaryTags(
        preferencesForm.dietaryTags,
        preferencesForm.dietaryRestrictions,
      ),
    };

    console.log("保存偏好设置数据:", preferencesData);
    const response = await api.put(
      `/api/users/${userId}/preferences`,
      preferencesData,
    );

    if (response.status === 200) {
      // 偏好变更后清理首页“猜你喜欢”缓存，确保推荐即时刷新
      const youMayLikeCacheKey = `home_you_may_like_dishes_${String(userId)}`;
      localStorage.removeItem(youMayLikeCacheKey);
      window.dispatchEvent(new Event("preferences-updated"));
      ElMessage.success("偏好设置保存成功");
    } else {
      ElMessage.error("保存失败，请稍后重试");
    }
  } catch (error) {
    console.error("保存偏好设置失败:", error);
    ElMessage.error("保存失败，请稍后重试");
  } finally {
    saving.value = false;
  }
};

// 修改密码
const changePassword = async () => {
  if (!passwordFormRef.value) return;
  await passwordFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        savingPassword.value = true;
        const userId = localStorage.getItem("userId");
        if (!userId) {
          ElMessage.error("请先登录");
          return;
        }
        await userApi.changePassword(userId, {
          oldPassword: passwordForm.oldPassword,
          newPassword: passwordForm.newPassword,
        });
        ElMessage.success("密码修改成功，请重新登录");
        
        // 登出逻辑
        const userStore = useUserStore();
        userStore.logout();
        router.push("/login");
      } catch (error) {
        console.error("修改密码失败:", error);
        ElMessage.error(error.response?.data?.message || "修改密码失败");
      } finally {
        savingPassword.value = false;
      }
    }
  });
};

// 获取所有可用的饮食标签
const loadAllDietaryTags = async () => {
  try {
    loadingTags.value = true;
    const response = await api.get("/api/users/dietary-tags");
    if (response.status === 200 && response.data) {
      allDietaryTags.value = normalizeTagList(response);
    }
  } catch (error) {
    console.error("加载饮食标签失败:", error);
    ElMessage.error("加载饮食标签失败，请稍后重试");
  } finally {
    loadingTags.value = false;
  }
};

// 加载用户信息
const loadUserInfo = async () => {
  try {
    const userId = localStorage.getItem("userId");
    if (!userId) {
      return;
    }

    // 调用API获取用户信息
    const response = await api.get(`/api/users/${userId}`);
    if (response.status === 200 && response.data) {
      const user = response.data;
      userForm.phone = user.phone || "";
      userForm.email = user.email || "";
      userForm.avatar = user.avatar || "";
      userForm.username = user.username || "";
      currentPoints.value = user.points || 0;
    }
  } catch (error) {
    console.error("加载用户信息失败:", error);
  }
};

// 加载用户当前偏好
const loadUserPreferences = async () => {
  try {
    const userId = localStorage.getItem("userId");
    if (!userId) {
      return;
    }

    // 调用API获取用户偏好
    const response = await api.get(`/api/users/${userId}`);
    if (response.status === 200 && response.data) {
      const user = response.data;
      if (user.spicinessLevel !== undefined)
        preferencesForm.spicinessLevel = user.spicinessLevel;
      if (user.sweetnessLevel !== undefined)
        preferencesForm.sweetnessLevel = user.sweetnessLevel;
      if (user.dietaryRestrictions !== undefined)
        preferencesForm.dietaryRestrictions = user.dietaryRestrictions;
      if (user.dietaryTags !== undefined)
        preferencesForm.dietaryTags = sanitizeDietaryTags(
          user.dietaryTags,
          user.dietaryRestrictions,
        );
    }
  } catch (error) {
    console.error("加载用户偏好失败:", error);
  }
};

// 组件挂载时加载用户信息、偏好和所有饮食标签
onMounted(() => {
  loadUserInfo();
  loadUserPreferences();
  loadAllDietaryTags();
  loadPointBalance();
  loadPointHistory();
  loadUnreadCount();
});

// 根据分类分组的标签
const groupedTags = computed(() => {
  const groups = {};

  // 收集所有预设标签
  const allPresetTags = new Set(Object.values(tagCategories).flat());

  // 过滤掉已经在主口味偏好部分显示的标签和忌口相关的标签
  const excludedTags = [
    "海鲜过敏",
    "不吃香菜",
    "不吃葱",
    "不吃蒜",
    "不吃羊肉",
    "爱吃肉",
    "清淡",
    "重口",
    "鲜香",
    "适中",
  ];

  // 获取当前API返回的标签集合
  const apiTags = new Set(allDietaryTags.value);

  // 初始化所有分类，并添加所有预设标签
  Object.entries(tagCategories).forEach(([category, tags]) => {
    groups[category] = tags.filter((tag) => !excludedTags.includes(tag));
  });

  // 过滤掉空分类
  Object.keys(groups).forEach((category) => {
    if (groups[category].length === 0) {
      delete groups[category];
    }
  });

  return groups;
});

const notifications = ref([]);
const notifTotal = ref(0);
const notifPage = ref(1);
const notifSize = ref(10);
const notifLoading = ref(false);
const notifFilterType = ref("");
const unreadCount = ref(0);
const notifDialogVisible = ref(false);
const selectedNotification = ref(null);

const formatNotificationType = (t) => {
  const map = {
    DISH: "菜品",
    PROMOTION: "促销",
    RESERVATION: "订单",
    COMMENT: "评价",
  };
  return map[t] || t || "未知";
};

const loadUnreadCount = async () => {
  try {
    const res = await notificationApi.getUnreadCount();
    const val = res?.data?.count;
    unreadCount.value =
      typeof val === "number" ? val : Number(val || 0);
  } catch (e) {
    unreadCount.value = unreadCount.value || 0;
  }
};

const loadNotifications = async () => {
  try {
    notifLoading.value = true;
    const params = {
      page: notifPage.value - 1,
      size: notifSize.value,
    };
    if (notifFilterType.value) params.type = notifFilterType.value;
    const res = await notificationApi.getUserNotifications(params);
    if (res.status === 200 && res.data) {
      const body = res.data;
      const list = Array.isArray(body.data) ? body.data : [];
      notifications.value = list;
      const total = body.totalElements ?? body.total ?? 0;
      notifTotal.value =
        typeof total === "number" ? total : Number(total || 0);
    } else {
      notifications.value = [];
      notifTotal.value = 0;
    }
  } catch (e) {
    notifications.value = [];
    notifTotal.value = 0;
  } finally {
    notifLoading.value = false;
  }
};

const handleNotifPageChange = (p) => {
  notifPage.value = p;
  loadNotifications();
};

const handleNotifTypeChange = () => {
  notifPage.value = 1;
  loadNotifications();
};

const openNotification = (row) => {
  selectedNotification.value = row;
  notifDialogVisible.value = true;
};

const handleMarkRead = async (row) => {
  try {
    await notificationApi.markAsRead(row.id);
    row.isRead = true;
    loadUnreadCount();
  } catch (e) {}
};

const handleMarkAllAsRead = async () => {
  try {
    await notificationApi.markAllAsRead();
    notifications.value.forEach((n) => {
      n.isRead = true;
    });
    loadUnreadCount();
  } catch (e) {}
};

const handleDeleteRead = async () => {
  try {
    await ElMessageBox.confirm(
      "确定要删除所有已读消息吗？此操作不可恢复。",
      "提示",
      {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      }
    );
    await notificationApi.deleteReadNotifications();
    ElMessage.success("删除成功");
    notifPage.value = 1;
    loadNotifications();
  } catch (e) {
    if (e !== "cancel") {
      console.error(e);
    }
  }
};

const goToBiz = (row) => {
  if (!row) return;
  const rawType = row.bizType || row.biz_type || row.type || "";
  const rawScene = row.scene || row.notificationScene || "";
  const bt = String(rawType).toUpperCase();
  const scene = String(rawScene).toUpperCase();
  const title = String(row.title || "");
  const content = String(row.content || "");
  const isReward = title.includes("奖励") || content.includes("积分");
  const isReply = title.includes("回复") || content.includes("回复");
  if (isReward) {
    activeTab.value = "points";
    notifDialogVisible.value = false;
    return;
  }
  if (scene === "ORDER_STATUS_CHANGE" || bt === "ORDER" || isReply) {
    notifDialogVisible.value = false;
    router.push("/orders").catch(() => {});
    return;
  }
  let path = "/home";
  if (bt === "DISH") {
    path = "/dishes";
  } else if (bt === "PROMOTION") {
    path = "/home";
  }
  const query = row.bizId ? { bizId: String(row.bizId) } : undefined;
  notifDialogVisible.value = false;
  router.push(query ? { path, query } : path).catch(() => {});
};

watch(
  () => activeTab.value,
  (v) => {
    if (v === "notifications") {
      loadUnreadCount();
      loadNotifications();
    }
  },
);
</script>

<style scoped>
.avatar-uploader {
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  width: 100px;
  height: 100px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.avatar-uploader:hover {
  border-color: #409eff;
}

.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 100px;
  height: 100px;
  text-align: center;
  line-height: 100px;
}

.avatar-wrapper {
  position: relative;
  width: 100px;
  height: 100px;
}

.avatar {
  width: 100px;
  height: 100px;
  display: block;
  object-fit: cover;
}

.avatar-mask {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  color: #fff;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  opacity: 0;
  transition: opacity 0.3s;
  cursor: pointer;
}

.avatar-wrapper:hover .avatar-mask {
  opacity: 1;
}

.avatar-mask .el-icon {
  font-size: 20px;
  margin-bottom: 5px;
}

.avatar-mask span {
  font-size: 12px;
}

.profile-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

.page-header {
  text-align: center;
  margin-bottom: 30px;
}

.page-title {
  font-size: 28px;
  color: #333;
  margin-bottom: 10px;
}

.page-subtitle {
  font-size: 16px;
  color: #666;
}

.profile-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  padding: 30px;
}

.profile-tabs-nav {
  margin-bottom: 30px;
}

.tab-content {
  padding: 20px 0;
}

.profile-form,
.preferences-form {
  max-width: 600px;
  margin: 0 auto;
}

.section {
  margin-bottom: 30px;
}

.section-title {
  font-size: 20px;
  color: #333;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 2px solid #f0f0f0;
}

.slider-container {
  display: flex;
  align-items: center;
  gap: 20px;
  width: 100%;
}

.slider-container :deep(.el-slider) {
  flex: 1;
  min-width: 200px;
}

.slider-value {
  min-width: 80px;
  font-weight: bold;
  color: #409eff;
}

.checkbox-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 15px;
  margin-top: 10px;
}

.tag-categories {
  margin-top: 10px;
}

.tag-category {
  margin-bottom: 25px;
  padding: 15px;
  background-color: #f9f9f9;
  border-radius: 8px;
}

.category-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 15px;
  padding-bottom: 8px;
  border-bottom: 1px solid #e0e0e0;
}

.category-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.tag-checkbox {
  margin-right: 0;
}

.no-tags {
  text-align: center;
  color: #999;
  padding: 20px;
  background-color: #f9f9f9;
  border-radius: 8px;
}

.form-actions {
  display: flex;
  justify-content: center;
  gap: 20px;
  margin-top: 40px;
  width: 100%;
  flex-wrap: wrap;
}

/* 积分中心样式 */
.points-overview {
  background: linear-gradient(135deg, #409eff 0%, #2c8cf0 100%);
  color: white;
  padding: 30px;
  border-radius: 12px;
  margin-bottom: 30px;
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  overflow: hidden;
}

.points-overview::after {
  content: "";
  position: absolute;
  top: -20px;
  right: -20px;
  width: 100px;
  height: 100px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50%;
}

.points-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  opacity: 0.9;
  margin-bottom: 10px;
}

.info-icon {
  font-size: 16px;
  cursor: pointer;
}

.points-value {
  font-size: 48px;
  font-weight: bold;
  margin-bottom: 20px;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.points-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.notify-toolbar {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 16px;
}
.unread-badge {
  margin-left: auto;
}
.notify-detail {
  line-height: 1.6;
  font-size: 15px;
}

.points-history {
  padding: 0 20px;
}

.loading-container {
  padding: 20px 0;
}

.empty-state {
  padding: 40px 0;
}

.history-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  background-color: #f9f9f9;
  border-radius: 8px;
  transition: all 0.3s;
}

.history-item:hover {
  background-color: #f0f8ff;
}

.history-content {
  flex: 1;
}

.history-title {
  font-size: 16px;
  color: #333;
  margin-bottom: 4px;
}

.history-source {
  font-size: 12px;
  color: #999;
}

.history-value {
  font-size: 18px;
  font-weight: bold;
  margin-left: 20px;
}

.history-value.earn {
  color: #67c23a;
}

.history-value.spend {
  color: #f56c6c;
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 30px;
}
</style>
